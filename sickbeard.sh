#! /bin/sh

QPKG_NAME=SickBeard
QPKG_DIR=$(/sbin/getcfg $QPKG_NAME Install_Path -f /etc/config/qpkg.conf)
PID_FILE=/tmp/$QPKG_NAME.pid
DAEMON=/opt/bin/python2.6
DAEMON_OPTS="SickBeard.py --daemon --pidfile $PID_FILE"

CheckQpkgEnabled() { #Is the QPKG enabled? if not exit the script 
	if [ $(/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf) = UNKNOWN ]; then
		/sbin/setcfg ${QPKG_NAME} Enable TRUE -f /etc/config/qpkg.conf
	elif [ $(/sbin/getcfg ${QPKG_NAME} Enable -u -d FALSE -f /etc/config/qpkg.conf) != TRUE ]; then
		/bin/echo "${QPKG_NAME} is disabled."
		exit 1
	fi
}

ConfigPython(){ #checks if the daemon exists and will link /usr/bin/python to it
	#python dependency checking
	if [ ! -x $DAEMON ]; then
		/sbin/write_log "Failed to start $QPKG_NAME, $DAEMON was not found. Please re-install the Pythton ipkg." 1 
		exit 1
	else
		#link python to /usr/bin/python to fix sabtosickbeard.py processing
		/bin/ln -sf $DAEMON /usr/bin/python
	fi
}

CheckForOpt(){ #Does /opt exist? if not check if it's optware that's installed or opkg, and start the package 
	/bin/echo -n " Checking for /opt..."
	if [ ! -d /opt/bin ]; then
		if [ -x /etc/init.d/Optware.sh ]; then #if optware ,start optware
			/bin/echo "  Starting Optware..."
			/etc/init.d/Optware.sh start
			sleep 2
		elif [ -x /etc/init.d/opkg.sh ]; then #if opkg, start opkg 	
			/bin/echo "  Starting Opkg..."		
			/etc/init.d/opkg.sh start
			sleep 2
		else #catch all
			/bin/echo "  No Optware or Opkg found, please install one of them"		
			/sbin/write_log "Failed to start $QPKG_NAME, no Optware or Opkg found. Please re-install one of those packages" 1 
			exit 1
		fi
	else
		/bin/echo "  Found!"
	fi
}

CheckQpkgRunning() { #Is the QPKG already running? if so, exit the script
	if [ -f $PID_FILE ]; then
		#grab pid from pid file
		Pid=$(/bin/cat $PID_FILE)
		if [ -d /proc/$Pid ]; then
			/bin/echo " $QPKG_NAME is already running" 
			exit 1
		fi
	fi
	#ok, we survived so the QPKG should not be running
}

UpdateQpkg(){ # does a git pull to update to the latest code
	/bin/echo "Updating $QPKG_NAME"
	cd $QPKG_DIR && /opt/bin/git reset --hard HEAD && /opt/bin/git pull && cd - && /bin/sync
}

StartQpkg(){ #Starts the qpkg
	/bin/echo "Starting $QPKG_NAME"
	cd $QPKG_DIR
	PATH=${PATH} ${DAEMON} ${DAEMON_OPTS}
}

ShutdownQPKG() { #kills a proces based on a PID in a given PID file
	/bin/echo "Shutting down ${QPKG_NAME}... "
	if [ -f $PID_FILE ]; then
		#grab pid from pid file
		Pid=$(/bin/cat $PID_FILE)
		i=0
		/bin/kill $Pid
		/bin/echo -n " Waiting for ${QPKG_NAME} to shut down: "
		while [ -d /proc/$Pid ]; do
			sleep 1
			let i+=1
			/bin/echo -n "$i, "
			if [ $i = 45 ]; then
				/bin/echo " Tired of waiting, killing ${QPKG_NAME} now"
				/bin/kill -9 $Pid
				/bin/rm -f $PID_FILE
				exit 1
			fi
		done
		/bin/rm -f $PID_FILE
		/bin/echo "Done"
	else
		/bin/echo "${QPKG_NAME} is not running?"
	fi
}

case "$1" in
  start)
	CheckQpkgEnabled #Check if the QPKG is enabled, else exit 
	/bin/echo "$QPKG_NAME prestartup checks..."
	CheckQpkgRunning #Check if the QPKG is not running, else exit
	CheckForOpt      #Check for /opt, start qpkg if needed
	ConfigPython	 #Check for Python, exit if not found
	UpdateQpkg		 #do a git pull
	StartQpkg		 #Finally Start the qpkg
	
	;;
  stop)
  	ShutdownQPKG
	;;
  restart)
	echo "Restarting $QPKG_NAME"
	$0 stop 
	$0 start
	;;
  *)
	N=/etc/init.d/$QPKG_NAME.sh
	echo "Usage: $N {start|stop|restart}" >&2
	exit 1
	;;
esac
