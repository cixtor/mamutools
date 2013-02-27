#!/bin/bash
#
# Database Dumper
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Database_dump
#
# In information technology, a backup, or the process of backing up, refers to
# the copying and archiving of computer data so it may be used to restore the
# original after a data loss event.
#
# Backups have two distinct purposes. The primary purpose is to recover data
# after its loss, be it by data deletion or corruption. The secondary purpose
# of backups is to recover data from an earlier time, according to a user-defined
# data retention policy, typically configured within a backup application for
# how long copies of data are required. Though backups popularly represent a
# simple form of disaster recovery, and should be part of a disaster recovery
# plan, by themselves, backups should not alone be considered disaster recovery.
#
# One reason for this is that not all backup systems or backup applications are
# able to reconstitute a computer system or other complex configurations such
# as a computer cluster, active directory servers, or a database server, by
# restoring only data from a backup.
#
# Since a backup system contains at least one copy of all data worth saving,
# the data storage requirements can be significant. Organizing this storage
# space and managing the backup process can be a complicated undertaking. A
# data repository model can be used to provide structure to the storage.
# Nowadays, there are many different types of data storage devices that are
# useful for making backups. There are also many different ways in which these
# devices can be arranged to provide geographic redundancy, data security, and
# portability.
#
MAXIMUN_BACKUP_FILES=10
BACKUP_FOLDERNAME='dbbackup'
DB_HOSTNAME='localhost'
DB_USERNAME='root'
DB_PASSWORD='password'
DATABASES=()
#
echo 'Bash Database Backup Tool'
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FOLDER="${BACKUP_FOLDERNAME}_${CURRENT_DATE}"
mkdir $BACKUP_FOLDER
#
# Iterate overthe database list and dump (in SQL) the content of each one
for DATABASE in ${DATABASE[@]}; do
    BACKUP_DATABASE_PATH="${BACKUP_FOLDER}/${DATABASE}.sql"
    echo "[+] Dumping database: ${DATABASE}"
    echo -n "    Began...: "; date
    mysqldump -h "${DB_HOSTNAME}" -u"${DB_USERNAME}" -p"${DB_PASSWORD}" "${DATABASE}" > "${BACKUP_DATABASE_PATH}"
    echo -n "    Finished: "; date
    if [ -e "${BACKUP_DATABASE_PATH}" ]; then
       echo "    Dumped successfully!"
    else
       echo "    Error dumping this database."
    fi
done
echo
#
echo '[+] Packaging and compressing the backup folder...'
tar -cv $BACKUP_FOLDER | bzip2 > ${BACKUP_FOLDER}.tar.bz2 && rm -rf $BACKUP_FOLDER
BACKUP_FILES_MADE=$(ls -1 ${BACKUP_FOLDERNAME}*.tar.bz2 | wc -l)
BACKUP_FILES_MADE=$(( $BACKUP_FILES_MADE - 0 )) # Convert into integer number.
echo
echo "[+] There are ${BACKUP_FILES_MADE} backup files actually."
if [ $BACKUP_FILES_MADE -gt $MAXIMUN_BACKUP_FILES ]; then
    REMOVE_FILES=$(( $BACKUP_FILES_MADE - $MAXIMUN_BACKUP_FILES ))
    echo "[+] Remove ${REMOVE_FILES} old backup files."
    ALL_BACKUP_FILES=$(ls -t1 ${BACKUP_FOLDERNAME}*.tar.bz2)
    SAFE_BACKUP_FILES=("$(ALL_BACKUP_FILES[@]:0:${MAXIMUN_BACKUP_FILES})") # Like: [0..10] in Ruby
    echo "[+] Safeting the newest backups files, and removing old files..."
    FOLDER_SAFETY="_safety"
    mkdir $FOLDER_SAFETY
    for FILE in ${SAFE_BACKUP_FILES[@]}; do
        mv -i $FILE $FOLDER_SAFETY/
    done
    rm -rfv ${BACKUP_FOLDERNAME}*.tar.bz2
    mv -i $FILE $FOLDER_SAFETY/* ./
    rm -rf $FILE $FOLDER_SAFETY
fi
#