#!/bin/bash
#
# Gravatar Information Gatherer
# http://cixtor.com/
# https://github.com/cixtor/mamutools
#
# An avatar is an image that represents a person online, basically a little
# picture that appears next to your name when you interact with websites. A
# Gravatar is a Globally Recognized Avatar. You upload it and create your
# profile just once, and then when you participate in any Gravatar-enabled site,
# your Gravatar image will automatically follow you there.
#
# Gravatar is a free service for site owners, developers, and users. It is
# automatically included in every WordPress account and is run and supported
# by Automattic.
#

if [[ "$1" == "" ]] || [[ "$1" =~ "help$" ]]; then
    echo "Gravatar Information Gatherer"
    echo "  http://cixtor.com/"
    echo "  https://github.com/cixtor/mamutools"
    echo "Usage:"
    echo "  $0 [username]"
    echo "  $0 [eaddress]"
    exit 2
fi

query="$1"
isemail=$(echo "$query" | grep --quiet '@')

if [[ "$?" -eq 0 ]]; then
    uniqueid=$(strconv -md5 -text "$query")
else
    uniqueid=$(strconv -urlenc -text "$query")
fi

response=$(
    curl "https://en.gravatar.com/${uniqueid}.json" \
    --header 'dnt: 1' \
    --header 'accept-language: en-US,en;q=0.8' \
    --header 'accept-encoding: gzip, deflate, sdch' \
    --header 'user-agent: Mozilla/5.0 (KHTML, like Gecko) Safari/537.36' \
    --header 'accept: text/html,application/xhtml+xml,application/xml' \
    --header 'cache-control: max-age=0' \
    --compressed --silent
)

if [[ "$response" == '"User not found"' ]]; then
    echo "{\"error\": ${response}}"
    exit 1
else
    if [[ $(which jq) ]]; then
        echo "$response" | jq '.'
    elif [[ $(which python) ]]; then
        echo "$response" | python -m json.tool
    else
        echo "$response"
    fi
fi
