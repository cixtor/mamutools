#!/bin/bash
#
# Tumblr Downloader
# https://github.com/cixtor/mamutools
# https://en.wikipedia.org/wiki/Tumblr
# https://en.wikipedia.org/wiki/Web_scraping
#
# Tumblr (stylized in its logo as tumblr.) is a microblogging platform and
# social networking website founded by David Karp and owned by Yahoo! Inc. The
# service allows users to post multimedia and other content to a short-form
# blog. Users can follow other users' blogs, as well as make their blogs
# private. Much of the website's features are accessed from the "dashboard"
# interface, where the option to post content and posts of followed blogs
# appear.
#

function checkPageExists() {
    curl --url "${1}" \
    --header 'DNT: 1' \
    --header 'Accept-Encoding: gzip, deflate, sdch' \
    --header 'Accept-Language: en-US,en;q=0.8' \
    --header 'Upgrade-Insecure-Requests: 1' \
    --header 'User-Agent: Mozilla/5.0 (KHTML, like Gecko) Safari/537.36' \
    --header 'Accept: text/html,application/xhtml+xml,application/xml' \
    --header 'Cache-Control: max-age=0' \
    --header 'Connection: keep-alive' \
    --write-out '%{http_code}' \
    --output /dev/null \
    --compressed --silent
}

function downloadImages() {
    if [[ "$1" != "" ]]; then
        target="$1"
        exists=$(checkPageExists "$target")
        echo -en "@ \e[0;94m${target}\e[0m "

        if [[ "$exists" == "200" ]]; then
            response=($(remoteassets -url "$target" -resource images))
            if [[ "$?" -eq 0 ]]; then
                echo -e "\e[0;92m\u2714\e[0m"
                for fileurl in "${response[@]}"; do
                    echo "$fileurl" | grep --quiet '\.media\.tumblr\.com'
                    if [[ "$?" -eq 0 ]]; then
                        fileurl=$(echo "$fileurl" | sed 's/_[0-9]\{3\}\./_1280\./g')
                        filename=$(echo "$fileurl" | rev | cut -d '/' -f 1 | rev)
                        echo -n "  - ${fileurl} "
                        wget -q "$fileurl" -O "$filename"
                        if [[ -e "$filename" ]]; then
                            echo -e "\e[0;92m\u2714\e[0m"
                        else
                            echo -e "\e[0;91m\u2718\e[0m"
                        fi
                    fi
                done
                return 0
            else
                echo -e "\e[0;91m\u2718\e[0m No resources"
            fi
        else
            echo -e "\e[0;91m\u2718\e[0m HTTP/1.1 ${exists}"
        fi
    fi
    return 1
}

if [[ "$1" == "" ]] || [[ "$1" =~ help ]]; then
    echo "Tumblr Downloader"
    echo "https://github.com/cixtor/mamutools"
    echo "https://en.wikipedia.org/wiki/Tumblr"
    echo
    echo "Usage:"
    echo "  $0 [username] [pages]"
    echo "  $0 google.tumblr.com 100"
    echo "  $0 google 100"
    exit 2
else
    if [[ $(which remoteassets) ]]; then
        website=$(echo "$1" | cut -d '.' -f 1)
        if [[ "$2" == "" ]]; then pages="1"; else pages="$2"; fi
        echo -e "Download \e[0;96m${website}/tumblr\e[0m"
        mkdir -pv -- "$website"

        if [[ -e "$website" ]]; then
            cd -- "$website"
        fi

        for ((key = 1; key <= $pages; key++)); do
            directory="page-${key}"
            echo -e "Creating page directory: \e[0;95m${website}/${directory}\e[0m"
            mkdir "$directory"; cd "$directory"

            if [[ "$key" -eq 1 ]]; then
                downloadImages "http://${website}.tumblr.com/"
                if [[ "$?" -eq 1 ]]; then
                    echo "  Website does not seems to exists"
                    echo "  Make sure your internet connection is working"
                    echo "  Load the blue URL above in your web browser"
                    exit 1
                fi
            else
                downloadImages "http://${website}.tumblr.com/page/${key}"
            fi

            echo -en "  \e[0;90mGoing to parent directory\e[0m"; cd ../; echo
            echo -en "  \e[0;90mSleeping for 30 seconds...\e[0m"; sleep 30; echo
        done
    else
        echo "RemoteAssets tool is required"
        echo "https://github.com/cixtor/mamutools"
        exit 1
    fi
fi
