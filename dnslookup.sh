#!/bin/bash
#
# DNS Lookup
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# https://en.wikipedia.org/wiki/Domain_Name_System
# https://en.wikipedia.org/wiki/Reverse_DNS_lookup
# https://en.wikipedia.org/wiki/List_of_DNS_record_types
#
# The Domain Name System (DNS) is a hierarchical distributed naming system for
# computers, services, or any resource connected to the Internet or a private
# network. It associates various information with domain names assigned to each
# of the participating entities. Most prominently, it translates domain names,
# which can be easily memorized by humans, to the numerical IP addresses needed
# for the purpose of computer services and devices worldwide. The Domain Name
# System is an essential component of the functionality of most Internet
# services because it is the Internet's primary directory service.
#
# In computer networking, reverse DNS lookup or reverse DNS resolution (rDNS) is
# the determination of a domain name that is associated with a given IP address
# using the Domain Name System (DNS) of the Internet.
#

domain="$1"
log_path="dnsquery-$(date +%s).log"
record_types=(
    'A'
    'CNAME'
    'MX'
    'NS'
    'SOA'
    'SRV'
    'TXT'
)
common_subdomains=(
    'blog'
    'cdn'
    'cpanel'
    'email'
    'forum'
    'forums'
    'ftp'
    'login'
    'm'
    'mail'
    'mx'
    'portal'
    'shop'
    'smtp'
    'store'
    'support'
    'webmail'
    'wp'
    'www'
)

if [[ "$1" == "" ]] || [[ "$@" =~ help ]]; then
    echo "DNS Lookup"
    echo "  http://cixtor.com/"
    echo "  https://github.com/cixtor/mamutools"
    echo "  https://en.wikipedia.org/wiki/Domain_Name_System"
    echo "  https://en.wikipedia.org/wiki/Reverse_DNS_lookup"
    echo "  https://en.wikipedia.org/wiki/List_of_DNS_record_types"
    echo "Usage:"
    echo "  $0 -help"
    echo "  $0 example.com"
    echo "  $0 example.com -full"
    exit 2
fi

echo "DNS Lookup for '${domain}'"
nameserver=$(dig -t "NS" +nocmd +noall +answer "$domain" | head -n1 | awk '{print $5}')

if [[ "$nameserver" == "" ]]; then
    echo "dig: couldn't get nameserver for '${domain}': not found"
    exit 1
else
    echo -n "Query for '${domain}' "
    for type in "${record_types[@]}"; do
        dig "@${nameserver}" -t "$type" +nocmd +noall +answer "$domain" 1>> $log_path
        echo -n "."
    done
    echo " OK"
    if [[ "$2" == "-full" ]]; then
        for name in "${common_subdomains[@]}"; do
            subdomain="${name}.${domain}"
            echo -n "Query for '${subdomain}' "
            for type in "${record_types[@]}"; do
                dig -t $type +nocmd +noall +answer "${subdomain}" "@${nameserver}" \
                | grep -vE '^;|SOA' | grep 'IN' \
                | grep "^$subdomain" 1>> $log_path
                echo -n "."
            done
            echo " OK"
        done
    fi
    echo; cat -- "$log_path" | uniq
    rm -- "$log_path" 2> /dev/null
    exit 0
fi
