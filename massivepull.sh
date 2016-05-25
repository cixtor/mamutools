#!/bin/bash
#
# Massive Repository Pull
# http://cixtor.com/
# https://github.com/cixtor/mamutools
#
# Being an autodidact developer I'm always looking new technologies to test out
# in my machine, counting new tools, languages and libraries. Almost sixty percent
# of all that information came to me in GIT Repositories, sometime ago I've created
# a script to clone those repositories mainly hosted on Github to compress those
# files in a BZip2 package, but then I wanted to have a tool to synchronize locally
# the latest version of some projects.
#
# Basically I used to execute the command git pull in many projects to get the latest
# version of some GIT Repository, but after some weeks that folder became tens of
# directories and obviously I don't want to waste my time checking manually all those
# repositories. I can write code, so I wrote a script to use in my crontab schedule
# and every week synchronize automatically all the changes in all the repositories,
# not only in my personal computer, but also in the servers I manage.
#
# 1. The script accept a unique parameter representing a location in the disk.
# 2. Check if the location provided is relative, in that case convert to an absolute path.
# 3. Find all the GIT Repositories in the absolute path specified.
# 4. Print the URL of the repository located generally in the file 'repository/.git/config'
# 5. Execute the command 'git pull' for each repository found.
#

function printDefaultOptions() {
    script=$(echo "$0" | rev | cut -d/ -f1 | rev)

    echo "@ Massive Repository Pull"
    echo "  https://github.com/cixtor/mamutools"
    echo "  Update Git repositories in given directory"
    echo "  Usage: ${script} /path/to/sources/"

    exit 2
}

IFS=$'\n'
CURRENT_PATH=$(pwd)
FOLDER=$1

if [[ "${FOLDER}" == "" ]]; then
    echo "Error: Missing directory"
    printDefaultOptions
fi

if [ "${FOLDER:0:1}" == "/" ]; then
    BASEPATH="${FOLDER%/}/"
else
    BASEPATH="${CURRENT_PATH}/${FOLDER%/}/"
fi

BASEPATH=$(echo "$BASEPATH" | sed 's/\/\.\//\//g')
BASEPATH_LENGTH=${#BASEPATH}

if [[ ! -e "${BASEPATH}" ]]; then
    echo "Error: Base directory does not exists"
    printDefaultOptions
fi

echo -n "Searching... "

QUANTITY=0
PACKAGES=()

for PACKAGE_FULLPATH in $(find "${BASEPATH}" -type d -iname ".git"); do
    PACKAGE_FULLPATH=$(echo "$PACKAGE_FULLPATH" | sed 's/\/\.git//g')
    PACKAGE=${PACKAGE_FULLPATH:$BASEPATH_LENGTH}
    QUANTITY=$(( QUANTITY + 1 ))
    PACKAGES+=($PACKAGE)
done

echo "${QUANTITY} repos found"
command -v git &> /dev/null

if [[ "$?" -eq 1 ]]; then
    echo "Error: Git is not available."
    echo "Install from: https://git-scm.com/"
    printDefaultOptions
fi

for package in "${PACKAGES[@]}"; do
    FULLPATH="${BASEPATH%/}/${package}"
    GIT_CONFIG="${FULLPATH}/.git/config"

    if [[ -e "$GIT_CONFIG" ]]; then
        REPOSITORY=$(grep "url.=" "$GIT_CONFIG" | tr -d ' ' | cut -d= -f2)
    fi

    echo
    echo -e "Checking updates: ${package}"
    echo -e "Fullpath: ${FULLPATH}"

    if [[ -e "$GIT_CONFIG" ]]; then
        echo -e "Repository: ${REPOSITORY}"
    fi

    if [[ -e "$FULLPATH" ]]; then
        cd "$FULLPATH" && git pull && echo "Finished."
    fi
done
