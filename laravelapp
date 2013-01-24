#!/bin/bash
#
# Laravel Application Generator
# http://www.cixtor.com/
# http://laravel.com/
#
# Laravel is a web application framework with expressive, elegant syntax. We
# believe development must be an enjoyable, creative experience to be truly
# fulfilling. Laravel attempts to take the pain out of development by easing
# common tasks used in the majority of web projects, such as authentication,
# routing, sessions, and caching.
#
# Laravel aims to make the development process a pleasing one for the developer
# without sacrificing application functionality. Happy developers make the best
# code. To this end, we've attempted to combine the very best of what we have
# seen in other web frameworks, including frameworks implemented in other languages,
# such as Ruby on Rails, ASP.NET MVC, and Sinatra.
#
# Laravel is accessible, yet powerful, providing powerful tools needed for large,
# robust applications. A superb inversion of control container, expressive migration
# system, and tightly integrated unit testing support give you the tools you need
# to build any application with which you are tasked.
#
PROJECT=$1
IFS=$'\n'
SEPARATOR=$(for i in {1..50}; do echo -n '-'; done; echo)
WRITE_DIRECTORIES=(
	'./app/storage/cache/'
	'./app/storage/logs/'
	'./app/storage/sessions/'
	'./app/storage/views/'
)
# Generate application name and clean the variable.
clear
echo -e "Laravel Application Generator"
echo $SEPARATOR
if [ "${PROJECT}" == "" ]; then
	echo -en "\e[0;94m[=]\e[0m Type the name of the application: "
	read PROJECT_NAME
	if [ "${PROJECT_NAME}" == "" ]; then
		PROJECT=$(echo app-$(date +'%Y%m%d'))
	else
		PROJECT=$PROJECT_NAME
	fi
fi
# Create project based on the latest version of the Laravel framework.
PROJECT=$(echo "${PROJECT}" | sed 's/ /-/g')
echo -e "\e[0;92m[+]\e[0m Creating application structure for: \e[0;93m${PROJECT}\e[0m"
echo $SEPARATOR
composer.phar -vv create-project laravel/laravel "${PROJECT}" --prefer-dist
# Clean up project (remove useless directories).
if [ -e "${PROJECT}" ]; then
	cd "${PROJECT}"
	CURRENT_SIZE=$(du -sh ./ | awk '{print $1}')
	DIRECTORIES=()
	for DIRECTORY in $(find ./ -type d -iname ".git"); do
		DIRECTORIES+=$DIRECTORY
		echo -e "Removing \e[0;93m${DIRECTORY}\e[0m"
		rm -rf "${DIRECTORY}"
	done
	FINAL_SIZE=$(du -sh ./ | awk '{print $1}')
	echo $SEPARATOR
	echo -e "\e[0;92m[+]\e[0m Cleaned up directory: \e[0;91m${CURRENT_SIZE}\e[0m => \e[0;92m${FINAL_SIZE}\e[0m"
	echo -e "\e[0;92m[+]\e[0m Granting write permissions:"
	for DIR in "${WRITE_DIRECTORIES[@]}"; do
		echo "    ${DIR}"
		chmod 777 "${DIR}"
	done
	echo -e "\e[0;92m    Finished.\e[0m"
else
	echo -e "\e[0;91m[x] Error:\e[0m Project folder was not created."
fi
#