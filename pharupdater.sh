#!/bin/bash
#
# Phar Updater
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://php.net/manual/en/intro.phar.php
#
# The phar extension provides a way to put entire PHP applications into a single
# file called a "phar" (PHP Archive) for easy distribution and installation.
# Phar archives are best characterized as a convenient way to group several
# files into a single file. As such, a phar archive provides a way to distribute
# a complete PHP application in a single file and run it from that file without
# the need to extract it to disk. Additionally, phar archives can be executed by
# PHP as easily as any other file, both on the commandline and from a web
# server. Phar is kind of like a thumb drive for PHP applications.
#

function usage_options() {
    echo "Usage: $0 [args]"
    echo "       $0 --target [dir] Installation directory"
    echo "       $0 --phpunit      Update PHP Unit-Test"
    echo "       $0 --phpdoc       Update PHP Documentor"
    echo "       $0 --phpcs        Update PHP CodeSniffer"
    echo "       $0 --phpcbf       Update PHP CodeSniffer Fixer"
    echo "       $0 --phploc       Update PHP Lines Of Code"
    echo "       $0 --phpcpd       Update PHP Copy/Paste Detector"
    echo "       $0 --phpmd        Update PHP Mess Detector"
    echo "       $0 --phpmetrics   Update PHP Metrics"
    echo "       $0 --wpcli        Update PHP WordPress CLI"
    echo "       $0 --all          Update all the supported tools"
}

function update_phpunit_tool() {
    if [[ $(echo "$1" | grep -- '--all\|--phpunit') ]]; then
        echo "- Updating PHPUnit "
        echo "  $(phpunit --version | tr -d '\n')"
        rm phpunit.phar
        wget --quiet 'https://phar.phpunit.de/phpunit.phar' -O phpunit.phar
        echo "  $(phpunit --version | tr -d '\n')"
    fi
}

function update_phpdoc_tool() {
    if [[ $(echo "$1" | grep -- '--all\|--phpdoc') ]]; then
        echo "- Updating PHPDocumentor"
        echo "  $(phpdoc --version)"
        echo "  average size ~33M (may take a while)"
        rm phpdoc.phar
        wget --quiet 'http://phpdoc.org/phpDocumentor.phar' -O phpdoc.phar
        echo "  $(phpdoc --version)"
    fi
}

if [[ "$1" == "" ]] || [[ "$1" =~ help ]]; then
    usage_options
    exit 2
fi

default_target="/opt/standalone/"
target_was_set=$(echo "$@" | grep --quiet '\-\-target')

if [[ "$?" -eq 0 ]]; then
    user_defined_target=$(echo "$@" | tr -d '-' | sed 's/.*target//g' | awk '{print $1}')
    if [[ -e "$user_defined_target" ]]; then
        echo "Updating of PHP Phar files"
        echo "Installation directory: ${user_defined_target}"

        update_phpunit_tool "$@"
        update_phpdoc_tool "$@"
    else
        echo "Error: Installation directory does not exists: ${user_defined_target}"
        usage_options
        exit 1
    fi
else
    echo "Error: Installation directory was not specified."
    usage_options
    exit 1
fi

if [[ $(which curl) ]]; then
    log_path='php_codesniffer.log'
    curl --silent --location 'https://github.com/squizlabs/PHP_CodeSniffer/releases/latest' > $log_path

    echo "- Updating PHPCodeSniffer"
    phpcs_url=$(cat $log_path | grep 'phpcs\.phar" rel="nofollow"' | cut -d '"' -f 2)
    if [[ "$phpcs_url" != "" ]]; then
        echo "  $(phpcs --version)"
        rm phpcs.phar
        wget --quiet "https://github.com/${phpcs_url}" -O phpcs.phar
        echo "  $(phpcs --version)"
    fi

    echo "- Updating PHPCodeSniffer Fixer"
    phpcbf_url=$(cat $log_path | grep 'phpcbf\.phar" rel="nofollow"' | cut -d '"' -f 2)
    if [[ "$phpcbf_url" != "" ]]; then
        echo "  $(phpcbf --version)"
        rm phpcbf.phar
        wget --quiet "https://github.com/${phpcbf_url}" -O phpcbf.phar
        echo "  $(phpcbf --version)"
    fi

    rm $log_path
fi

echo "- Updating PHPLOC (Lines Of Code)"
echo "  $(phploc --version)"
rm phploc.phar
wget --quiet 'https://phar.phpunit.de/phploc.phar' -O phploc.phar
echo "  $(phploc --version)"

echo "- Updating PHPCPD (Copy/Paste Detector)"
echo "  $(phpcpd --version)"
rm phpcpd.phar
wget --quiet 'https://phar.phpunit.de/phpcpd.phar' -O phpcpd.phar
echo "  $(phpcpd --version)"

echo "- Updating PHPMD (Mess Detector)"
echo "  $(phpmd --version)"
rm phpmd.phar
wget --quiet 'http://static.phpmd.org/php/latest/phpmd.phar' -O phpmd.phar
echo "  $(phpmd --version)"

echo "- Updating PHP Metrics"
echo "  $(phpmetrics --version)"
rm phpmetrics.phar
wget --quiet 'https://raw.githubusercontent.com/Halleck45/PhpMetrics/master/build/phpmetrics.phar' -O phpmetrics.phar
echo "  $(phpmetrics --version)"

echo "- Updating WordPress CLI"
echo "  $(wpcli --version)"
rm wpcli.phar
wget --quiet 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar' -O wpcli.phar
echo "  $(wpcli --version)"

echo "Finished"
