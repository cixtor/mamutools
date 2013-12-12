#!/bin/bash
#
# Latest Repository Downloader
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
#
# Sometime ago I wrote a Script to fetch dynamically multiple GIT repositories at
# once and now I have a folder with several folders sizing more than 20 GB, so I
# decided to write a different tool to do the same thing (fetch an remote repository)
# but instead of maintain the commit history I will automatically remove the ".git"
# folder once the code is downloaded and rename the configuration file containing
# the URL of the repository in a different path so when I execute the script again
# inside that folder it should detect automatically that it is a GIT repository but
# containing just the latest version of the code. That way I can update the code
# whenever I want and decrease the quantity of disk needed to store those projects.
#
function help {
    echo 'Latest Repository Downloader'
    echo '  http://www.cixtor.com/'
    echo '  https://github.com/cixtor/mamutools'
    echo
    echo "Usage: $0 [clone|pull] [dirname|remote_repository]"
    echo
}
function clone_repository {
    repository=$1
    if [ "${repository}" != "" ]; then
        directory=$(echo "${repository}" | rev | cut -d '/' -f 1 | rev | tr 'A-Z' 'a-z')
        git clone "${repository}" "${directory}"
        mv -i "${directory}/.git/config" "${directory}/.gitconfig"
        rm -rf "${directory}/.git"
    fi
}
help
if [ "${1}" == "pull" ]; then
    directory=$2
    if [ -d "${directory}" ]; then
        cd "${directory}"
        if [ -e ".gitconfig" ]; then
            repository=$(cat .gitconfig | grep 'url = ' | tr -d ' ' | awk -F '=' '{print $2}')
            if [ "${repository}" != "" ]; then
                cd ../ && rm -rf "${directory}"
                clone_repository $repository
            fi
        fi
    fi
elif [ "${1}" == "clone" ]; then
    clone_repository $1
fi
#