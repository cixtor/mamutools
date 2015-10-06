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
    echo; cat -- "$log_path" | uniq
    rm -- "$log_path" 2> /dev/null
    exit 0
fi
