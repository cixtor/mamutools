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
            else
                echo -e "\e[0;91m\u2718\e[0m No resources"
            fi
        else
            echo -e "\e[0;91m\u2718\e[0m HTTP/1.1 ${exists}"
        fi
    fi
}
