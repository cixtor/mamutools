#!/bin/bash
#
# Database Dumper
# http://cixtor.com/
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
DATABASES=(
    'information_schema'
    'mysql'
    'test'
)

function success {
    echo -e "\e[0;92mOK.\e[0m ${1}"
}

function warning {
    echo -e "\e[0;93m[!]\e[0m ${1}"
}

function warning_wait {
    echo -en "\e[0;93m[!]\e[0m ${1}"
}

function error {
    echo -e "\e[0;91m[x] Error.\e[0m ${1}"
}

function fail {
    error $1
    exit
}

function initialize {
    echo 'Database Dumper'
    echo '    http://cixtor.com/'
    echo '    https://github.com/cixtor/mamutools'
    echo '    http://en.wikipedia.org/wiki/Database_dump'
    echo

    cd $(dirname $0)
    CWD=$(pwd)
    success "Current working directory (CWD): \e[0;93m${CWD}\e[0m"
    CURRENT_DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_FOLDER="${BACKUP_FOLDERNAME}_${CURRENT_DATE}"
    mkdir $BACKUP_FOLDER

    if [ ! -d "${BACKUP_FOLDER}" ]; then
        fail 'Root backup folder was not created.'
    fi
}

function count_databases {
    COUNT=0

    for DATABASE in ${DATABASES[@]}; do COUNT=$(( COUNT + 1)); done

    if [ $COUNT -gt 0 ]; then
        success "\e[0;93m${COUNT}\e[0m databases will be backed up"
    else
        fail 'There are not databases to create the backup package'
    fi
}

function dump_databases {
    # Iterate overthe database list and dump (in SQL) the content of each one
    for DATABASE in ${DATABASES[@]}; do
        BACKUP_DATABASE_PATH="${BACKUP_FOLDER}/${DATABASE}.sql"
        warning "Dumping database: ${DATABASE} ..."
        DUMP_BEGIN_TIME=$(date)
        mysqldump -h "${DB_HOSTNAME}" -u"${DB_USERNAME}" -p"${DB_PASSWORD}" "${DATABASE}" > "${BACKUP_DATABASE_PATH}"
        DBDUMP_SUCCEEDED=$?
        DUMP_FINISH_TIME=$(date)
        echo "    Began...: ${DUMP_BEGIN_TIME}"
        echo "    Finished: ${DUMP_FINISH_TIME}"
        echo -n "    "

        if [ "${DBDUMP_SUCCEEDED}" -eq 0 ];
            then success 'Dumped successfully!';
            else error 'Database dump failed';
        fi
    done
    echo
}

function package_backup {
    warning_wait 'Package and compress the backup folder... '
    tar -c $BACKUP_FOLDER | bzip2 > ${BACKUP_FOLDER}.tar.bz2 && rm -rf $BACKUP_FOLDER
    BACKUP_FILES_MADE=$(ls -1 ${BACKUP_FOLDERNAME}*.tar.bz2 | wc -l)
    BACKUP_FILES_MADE=$(( $BACKUP_FILES_MADE - 0 )) # Convert into integer number.
    success

    warning "\e[0;93m${BACKUP_FILES_MADE}\e[0m backup files currently exist"
    if [ $BACKUP_FILES_MADE -gt $MAXIMUN_BACKUP_FILES ]; then
        REMOVE_FILES=$(( $BACKUP_FILES_MADE - $MAXIMUN_BACKUP_FILES ))
        warning "Remove \e[0;93m${REMOVE_FILES}\e[0m old backup files"
        ALL_BACKUP_FILES=($(ls -tr1 ${BACKUP_FOLDERNAME}*.tar.bz2))
        SAFE_BACKUP_FILES=("${ALL_BACKUP_FILES[@]:0:${MAXIMUN_BACKUP_FILES}}") # Like: [0..10] in Ruby

        warning 'Saving newest backup files and removing the old ones:'
        FOLDER_SAFETY='_safety'
        mkdir $FOLDER_SAFETY

        for FILE in ${SAFE_BACKUP_FILES[@]}; do
            mv -i $FILE $FOLDER_SAFETY/
        done

        for FILE in $(ls -1 ${BACKUP_FOLDERNAME}*.tar.bz2); do
            echo -n '    ' && rm -fv $FILE;
        done

        success 'These backup files are the newest:'
        cd $FOLDER_SAFETY

        for FILE in $(ls -1 *.tar.bz2); do
            echo -n '    ' && echo $FILE
            mv -i $FILE ../
        done

        cd ../ && rm -rf $FOLDER_SAFETY
    fi
}

initialize
count_databases
dump_databases
package_backup
success 'Finished'
