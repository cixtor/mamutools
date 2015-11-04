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

domain_name="$1"
action_name="$2"
is_private="false"
servers=(
    '8e84827#USA, Dallas'
    'f1506d2#UK, London'
    'efae235#JP, Tokyo'
    '355689c#USA, Los Angeles'
    '3f55894#Canada, Montreal'
    '57e38d3#France, Paris'
    '51bd240#Singapore'
    'b688898#USA, Atlanta'
    'b688899#USA, New York'
    '78c55bd#NL, Amsterdam'
    '198baae#Australia, Sydney'
    'f22400e#Brazil/Sao Paulo'
    'u60o9aq#Germany/Frankfurt'
)

if [[ $(echo "$@" | grep -- '--private') ]]; then
    is_private="true"
fi

if [[ "$domain_name" == "" ]]; then
    domain_name="-help"
fi

if [[ "$domain_name" =~ "help$" ]]; then
    echo "Speed Test"
    echo "  http://cixtor.com/"
    echo "  https://github.com/cixtor/mamutools"
    echo "  http://en.wikipedia.org/wiki/Time_To_First_Byte"
    echo "  https://performance.sucuri.net/"
    echo
    echo "This test measures how long it takes to connect to your site and for one page to"
    echo "fully load. A very important value to pay attention is the 'time to first byte',"
    echo "which gives us how long it took for the content to be sent back to browser to"
    echo "start processing the page."
    echo
    echo "Usage:"
    echo "  $0 [domain] [options]"
    echo "  $0 -help                Print this message."
    echo "  $0 example.com          Start the performance test with that domain."
    echo "  $0 example.com -full    Start test and print all JSON responses"
    echo "  $0 example.com -local   Start test from local network"
    echo "  $0 example.com -private Do not show the results on the boards"
    exit 2
fi

echo "@ Testing domain '${domain_name}'"

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

if [[ "$action_name" == "-full" ]]; then
    echo "- Geo-locating domain ..."
    geo_location=$(
        curl --silent 'https://performance.sucuri.net/index.php?ajaxcall' \
        --header 'dnt: 1' \
        --header 'pragma: no-cache' \
        --header 'accept-encoding: gzip, deflate' \
        --header 'accept-language: en-US,en;q=0.8' \
        --header 'x-requested-with: XMLHttpRequest' \
        --header 'accept: application/json, text/javascript, */*; q=0.01' \
        --header 'user-agent: Mozilla/5.0 (KHTML, like Gecko) Safari/537.36' \
        --header 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
        --header 'referer: https://performance.sucuri.net/' \
        --header 'origin: https://performance.sucuri.net' \
        --header 'cache-control: no-cache' \
        --data 'geo_location=1' \
        --data "is_private=${is_private}" \
        --data "domain=${domain_name}" \
        --compressed
    )
    echo "$geo_location" | jq '.'
fi

if [[ "$action_name" == "-local" ]]; then
    statistics=""
    statistics+="  Connection:  %{time_connect} secs\n"
    statistics+="  FirstByte:   %{time_starttransfer} secs\n"
    statistics+="  TotalTime:   %{time_total} secs\n"
    statistics+="  NameLookup:  %{time_namelookup} secs\n"
    statistics+="  Redirection: %{time_redirect} secs\n"
    curl --silent "$domain_name" --location --write-out "$statistics" -o /dev/null
else
    echo -e "\e[0;2m  Status: Connection Time, First Byte Time, Total Time\e[0m"
    for server in "${servers[@]}"; do
        server_unique=$(echo "$server" | cut -d '#' -f 1)
        server_name=$(echo "$server" | cut -d '#' -f 2)

        echo -en "- Testing server '\e[0;33m${server_unique}\e[0m' -> "
        response=$(
            curl --silent 'https://performance.sucuri.net/index.php?ajaxcall' \
            --header 'dnt: 1' \
            --header 'pragma: no-cache' \
            --header 'accept-encoding: gzip, deflate' \
            --header 'accept-language: en-US,en;q=0.8' \
            --header 'x-requested-with: XMLHttpRequest' \
            --header 'accept: application/json, text/javascript, */*; q=0.01' \
            --header 'user-agent: Mozilla/5.0 (KHTML, like Gecko) Safari/537.36' \
            --header 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
            --header 'referer: https://performance.sucuri.net/' \
            --header 'origin: https://performance.sucuri.net' \
            --header 'cache-control: no-cache' \
            --data 'form_action=test_load_time' \
            --data 'load_time_tester=1' \
            --data "is_private=${is_private}" \
            --data "location=${server_unique}" \
            --data "domain=${domain_name}" \
            --compressed
        )

        if [[ "$action_name" == "-full" ]]; then
            echo "$response" | jq '.'
        else
            status=$(echo "$response" | jq -r '.status')
            CN=$(echo "$response" | jq -r '.output.connect_time')
            FB=$(echo "$response" | jq -r '.output.firstbyte_time')
            TT=$(echo "$response" | jq -r '.output.total_time')

            if [[ "$status" == "1" ]]; then
                echo -en "\e[0;42m ${status} \e[0m"
            else
                echo -en "\e[0;41m ${status} \e[0m"
            fi

            echo -en " ${CN}, ${FB}, ${TT}"
            echo -en " \e[0;2m${server_name}\e[0m"
            echo
        fi
    done
fi

if [[ "$action_name" == "-full" ]]; then
    echo "- Retrieving cache data ..."
    cache_data=$(
        curl --silent 'https://performance.sucuri.net/index.php?ajaxcall' \
        --header 'dnt: 1' \
        --header 'pragma: no-cache' \
        --header 'accept-encoding: gzip, deflate' \
        --header 'accept-language: en-US,en;q=0.8' \
        --header 'x-requested-with: XMLHttpRequest' \
        --header 'accept: application/json, text/javascript, */*; q=0.01' \
        --header 'user-agent: Mozilla/5.0 (KHTML, like Gecko) Safari/537.36' \
        --header 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
        --header 'referer: https://performance.sucuri.net/' \
        --header 'origin: https://performance.sucuri.net' \
        --header 'cache-control: no-cache' \
        --data 'get_cache=1' \
        --data "domain=${domain_name}" \
        --compressed
    )
    echo "$cache_data" | jq '{action: .action, cache_exists: .cache_exists,
        domain_name: .domain_name, is_cache_usable: .is_cache_usable,
        is_correct_id: .is_correct_id, max_tests: .max_tests,
        message: .message, status: .status, total_tests: .total_tests}'
fi

if [[ $(which notify-send) ]]; then
    notify-send 'Sucuri Performance Test' \
    "Finished testing '$domain_name'" \
    -i 'dialog-information'
fi

echo "  Finished"
exit 0
