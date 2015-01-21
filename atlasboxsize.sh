#!/bin/bash
#
# Atlas Box Size
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# https://atlas.hashicorp.com/boxes/search
#
# Vagrant Cloud was a product HashiCorp launched to support the hosting and
# discovery of Vagrant Boxes, as well as other features like Vagrant Share.
# Recently, it has been moved into Atlas. Atlas provides functionality beyond
# Vagrant Cloud, but still what was initially offered. You can learn more about
# Atlas on the homepage.
#

if [[ "$1" == "" ]] || [[ "$1" =~ help ]]; then
    echo "Usage: $0 [atlas_box_url]"
    echo "       $0 https://atlas.hashicorp.com/chef/boxes/centos-7.0"
    echo "       $0 https://atlas.hashicorp.com/ubuntu/boxes/trusty64"
    echo "       $0 https://atlas.hashicorp.com/hashicorp/boxes/precise64"
    exit 2
else
    atlas_url="$1"
    base_url=$(echo "$atlas_url" | sed 's/.*:\/\///g')
    owner=$(echo "$base_url" | cut -d '/' -f 2)
    box_name=$(echo "$base_url" | cut -d '/' -f 4)
    version=$(curl --silent \
        --url "$atlas_url" \
        --header 'DNT: 1' \
        --header 'Accept-Language: en-US,en;q=0.8' \
        --header 'Accept-Encoding: gzip, deflate, sdch' \
        --header 'User-Agent: Mozilla/5.0 (KHTML, like Gecko) Safari/537.36' \
        --header 'Accept: text/html,application/xhtml+xml,application/xml' \
        --header 'Cache-Control: max-age=0' \
        --header 'Connection: keep-alive' \
        --compressed \
        | grep '/versions/' \
        | head -n 1 | tr -d ' ' \
        | cut -d '"' -f 2 | rev \
        | cut -d '/' -f 1 | rev
    )
    box_url="https://atlas.hashicorp.com/${owner}/boxes/${box_name}/versions/${version}/providers/virtualbox.box"
    echo "OwnerBox: ${owner}/${box_name}"
    echo "Base URL: $base_url"
    echo "Box URL.: $box_url"
    if [[ $(which filesize) ]]; then
        filesize "$box_url"
    else
        curl --head "$box_url" --silent --location | grep -i '^content-length'
    fi
    exit 0
fi
