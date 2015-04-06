#!/bin/bash
#
# Speed Test
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Time_To_First_Byte
# https://performance.sucuri.net/
#
# This test measures how long it takes to connect to your site and for one page
# to fully load. A very important value to pay attention is the 'time to first
# byte', which gives us how long it took for the content to be sent back to
# browser to start processing the page.
#
# Time To First Byte or TTFB is a measurement that is often used as an
# indication of the responsiveness of a webserver or other network resources. It
# is the duration from the virtual user making an HTTP request to the first byte
# of the page being received by the browser. This time is made up of the socket
# connection time, the time taken to send the HTTP request, and the time taken
# to get the first byte of the page.
#

curl_version=$(curl --version 2> /dev/null)
if [[ "$?" -ne 0 ]]; then
    echo "error: This tool requires CURL to work"
    echo "download: http://curl.haxx.se/"
    exit 1
fi

jq_version=$(jq --version 2> /dev/null)
if [[ "$?" -ne 0 ]]; then
    echo "error: This tool requires JQ to work"
    echo "download: http://stedolan.github.io/jq/"
    exit 1
fi
