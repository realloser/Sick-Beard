import sys
import os, stat
import os.path
import subprocess

def executeRename(dirName):
	
	# check whether the file exists in the folder
	linux2rename = os.path.join(os.path.dirname(dirName), "Linux_2rename.sh")
	if os.path.isfile(linux2rename):
		print "Executing ", linux2rename
		# make sure the shell can be executed
		os.chmod(linux2rename, stat.S_IXGRP)
		os.chmod(linux2rename, stat.S_IXUSR)
		subprocess.call([linux2rename])
	else: 
		print "File", linux2rename, "not found"

# print sys.argv[1]
# executeRename(sys.argv[1])