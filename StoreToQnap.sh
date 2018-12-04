#!/bin/bash

# File with global variables and functions
source /root/scripts/management/geralVars.sh

# BACKUP - hostx (172.20.0.8)
# \\172.20.0.8\d$\
# to $SHARE (qnap2 172.20.0.55)


# Share name
SHARE="/BACKUP3"


#------------Included/Excluded - File Directories--------------

# files produced by users (network area)

#The included source directorys:
#MainFolder/***
#public/***

INC="/root/scripts/backupScripts/files/StoreToQnap_inc.txt"

#The excluded source directorys:
#/root/scripts/backupScripts/files/StoreToQnap_exc.txt
#*

EXC="/root/scripts/backupScripts/files/StoreToQnap_exc.txt"

#----------------------------------------------------------------

#The source directory:
SRC="/backup-tmp-prodMount"

#The target directory:
TRG=$SHARE"/FILES/Store/Files/back-"

#The current backup directory:
CUR=$SHARE"/FILES/Store/Files/current"

#The log file:
LOG=$SHARE"/FILES/Store/storeBackup.log"

#The current date and time
date=`date "+%Y-%m-%dT%H:%M:%S"`


##################################################################################################################################################################

##A similar instruction was placed in fstab so the folder could be mounted
###mount -t cifs //172.20.0.8/d\$/ $SRC -o credentials=/root/scripts/management/cifs_credentials/.tales_credentials

###from fstab

### Hostx (Origin location)
###//172.20.0.8/d$/                /backup-tmp-prodMount           cifs            credentials=/root/scripts/management/cifs_credentials/.hostx_credentials   
###QNAP2 (Backups location)
### 172.20.0.55:/share/CACHEDEV1_DATA/BACKUP3               /BACKUP3                nfs             rsize=8192,wsize=8192,timeo=14,intr

##################################################################################################################################################################


echo Started at `date` >> $LOG

#Execute the backup and log
rsync -av --delete --include-from=$INC --exclude-from=$EXC --link-dest=$CUR $SRC $TRG$date >> $LOG

rsyncExitCode=$?;

# If rsync successefuly concludes, a link is created to the last backup folder.
# 0 means success.
if [ $rsyncExitCode = 0 ]; then

	echo Finiched at `date` >> $LOG
	echo '*********************************************************************' >> $LOG

	rm -rf $CUR
	ln -s $TRG$date $CUR

else

	echo Finiched at `date` >> $LOG
	echo '*********************************************************************' >> $LOG
	
	# if rsync fails an email alert is sent
	echo -e "rsync failure - StoreToQnap.sh" | mutt -s "rsync failure" "alert@xxdomainxx.pt"

fi

#########################################################################################
# Copys what is in the file storeBackup.log to storeBackupTotal.log
# Copy every line of the file storeBackup.log to one DB
# Deletes the content of storeBackup.log
	cat $LOG >> $SHARE"/FILES/Store/storeBackupTotal.log"
	/root/scripts/phpScripts/storeLogToDB.php
	echo "" > $LOG
#########################################################################################

# it is not to unmount anymore
##umount $SRC

## MAINTENANCE ##
echo "in Maintenance..."
# Path to the folder that we whant do search
delDIR=$SHARE"/FILES/Store/Files/"
# Location to the file log where we whant to register what is being deleted
delLOG=$SHARE"/FILES/Store/storeBackup_deleted.log"
maintenance2 $delDIR $delLOG
