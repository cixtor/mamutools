#!/bin/bash
#
# Massive Repository Pull
# http://www.cixtor.com/
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
clear
SEPARATOR=$(for(( i=0; i<50; i++ )); do echo -n '-'; done; echo)
echo "[+] Massive Repository Pull"
echo "    @desc.: Search for GIT repositories in a specific location and try to update them."
echo "    @usage: Usage: ${0} ./folder/path"
echo
#
IFS=$'\n'
CURRENT_PATH=$(pwd)
FOLDER=$1
if [ "${FOLDER}" != "" ]; then
	if [ ${FOLDER:0:1} == "/" ]; then
		BASEPATH="${FOLDER%/}/"
	else
		BASEPATH="${CURRENT_PATH}/${FOLDER%/}/"
	fi
	BASEPATH=$(echo $BASEPATH | sed 's/\/\.\//\//g')
	BASEPATH_LENGTH=${#BASEPATH}
	echo -e "[+] Search repositories in \e[1;33m${BASEPATH}\e[0m"
	if [ -e "${BASEPATH}" ]; then
		QUANTITY=0
		PACKAGES=()
		PACKAGES_FULLPATH=$(find "${BASEPATH}" -type d -iname ".git" | sed 's/\/\.git//g')
		for PACKAGE_FULLPATH in $PACKAGES_FULLPATH; do
			PACKAGE=${PACKAGE_FULLPATH:$BASEPATH_LENGTH}
			QUANTITY=$(($QUANTITY + 1))
			PACKAGES+=($PACKAGE)
		done
		echo -e "    \e[0;32m${QUANTITY} repositories were found.\e[0m"
		echo
		if [ $(which git) ]; then
			for package in "${PACKAGES[@]}"; do
				FULLPATH="${BASEPATH%/}/${package}"
				GIT_CONFIG="${FULLPATH}/.git/config"
				IS_GITHUB=$(if [ -e "${GIT_CONFIG}" ]; then echo 1; else echo 0; fi )
				if [ $IS_GITHUB == 1 ]; then
					REPOSITORY=$(grep 'url =' "${GIT_CONFIG}" | tr -d ' ' | cut -d '=' -f 2)
				fi
				echo -e "\e[0;33mChecking version for:\e[0m \e[1;34m${package}\e[0m"
				echo -e "\e[0;33mFullpath:\e[0m ${FULLPATH}"
				if [ $IS_GITHUB == 1 ]; then
					echo -e "\e[0;33mRepository:\e[0m ${REPOSITORY}"
				fi
				if [ -e $FULLPATH ]; then
					cd $FULLPATH
					git pull
					echo -e "\e[0;32mFinished.\e[0m"
					echo
				else
					echo -e "\e[0;31mThe package\e[0m \e[1;31m${package}\e[0m \e[0;31mdoesn't exists.\e[0m"
				fi
			done
		else
			echo -e "\e[1;31mError:\e[0m GIT was not detected in your system."
		fi
	else
		echo -e "\e[1;31mError:\e[0m The basepath '\e[0;31m${BASEPATH}\e[0m' does not exists."
	fi
else
	echo -e "\e[1;31mError:\e[0m You should specify a path to search, use '\e[1;31m./\e[0m' to search in this location."
fi
#