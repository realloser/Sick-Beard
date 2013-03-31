#!/bin/sh

# Stop the service before we begin the removal.
if [ -x /etc/init.d/sickbeard.sh ]; then
/etc/init.d/sickbeard.sh stop
/bin/sleep 5
/bin/sync
fi

# Package specific routines as defined in package_routines.


# Remove QPKG directory, init-scripts, and icons.
/bin/rm -fr "/share/MD0_DATA/.qpkg/SickBeard"
/bin/rm -f "/etc/init.d/sickbeard.sh"
/usr/bin/find /etc/rcS.d -type l -name 'QS*SickBeard' | /usr/bin/xargs /bin/rm -f 
/usr/bin/find /etc/rcK.d -type l -name 'QK*SickBeard' | /usr/bin/xargs /bin/rm -f
/bin/rm -f "/home/httpd/RSS/images/SickBeard.gif"
/bin/rm -f "/home/httpd/RSS/images/SickBeard_80.gif"
/bin/rm -f "/home/httpd/RSS/images/SickBeard_gray.gif"

# Package specific routines as defined in package_routines.


# Package specific routines as defined in package_routines.


