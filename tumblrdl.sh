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
