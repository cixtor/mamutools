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
    echo "Usage: $0 [remote_repository]"
    echo
}
function get_latest_code {
    repository=$1
    if [ "${repository}" != "" ]; then
        directory=$2
        if [ "${directory}" == "" ]; then
            directory=$(echo "${repository}" | rev | cut -d '/' -f 1 | rev)
        fi
        git clone "${repository}" "${directory}"
        mv -i "${directory}/.git/config" "${directory}/.gitconfig"
        rm -rf "${directory}/.git"
    fi
}
help
get_latest_code $1 $2
#