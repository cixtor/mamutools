#!/bin/bash
if [[ "$1" =~ help ]]; then
    echo "Check if an email has been pwned"
    echo "Usage: $0 [email]"
    exit 2
fi

EADDRESS=$([[ "$1" == "" ]] && echo "noreply@example.com" || echo "$1")
EADDRESS=$(echo "$EADDRESS" | sed 's;@;%40;')
RESPONSE=$(
    curl "https://heroic.com/wp-admin/admin-ajax.php" \
    -H "accept-language: en-US,en;q=0.8" \
    -H "accept-encoding: gzip, deflate, br" \
    -H "user-agent: Mozilla/5.0 (KHTML, like Gecko) Safari/537.36" \
    -H "content-type: application/x-www-form-urlencoded; charset=UTF-8" \
    -H "referer: https://heroic.com/email-security/" \
    -H "x-requested-with: XMLHttpRequest" \
    -H "origin: https://heroic.com" \
    -H "authority: heroic.com" \
    --data "action=heroic_scan_email" \
    --data "data[email]=${EADDRESS}" \
    --compressed --silent
)

if command -v php &> /dev/null; then
    php -r "print(json_encode(unserialize(urldecode('${RESPONSE}'))));"
else
    echo "PHP is required in order to decode the data"
    exit 1
fi
