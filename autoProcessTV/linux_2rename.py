import sys
import os, stat
import os.path
import subprocess

def executeRename(dirName):
	
	# check whether the file exists in the folder
	linux2rename = os.path.join(dirName, "Linux_2rename.sh")
	if os.path.isfile(linux2rename):
		origCWD = os.getcwd()
		try:
			# set the working dir
			print "Changeing working dir to", dirName
			os.chdir(dirName)
			# make sure the shell can be executed
			print "Make the file executable"
			os.chmod(linux2rename, stat.S_IXGRP)
			os.chmod(linux2rename, stat.S_IXUSR)
			print "Executing ", linux2rename
			subprocess.call([linux2rename])
		except Exception, e:
			print "Failed to run", linux2rename, ": ", e
		finally:
			# reset the working dir
			print "Reset the working dir to", origCWD
			os.chdir(origCWD)

		
	else: 
		print "File", linux2rename, "not found"

# print sys.argv[1]
# executeRename(sys.argv[1])