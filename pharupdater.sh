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
    if [[ $(echo "$@" | grep -- '--all\|--phpunit') ]]; then
        echo "- Updating PHPUnit "
        echo -n "  Old version: "
        phpunit.phar --version 2> /dev/null || echo '0.0.0'
        rm phpunit.phar 2> /dev/null
        wget --quiet 'https://phar.phpunit.de/phpunit.phar' -O phpunit.phar
        chmod 755 phpunit.phar
        echo -n "  New version: "
        ./phpunit.phar --version 2> /dev/null || echo '0.0.0'
    fi
}

function update_phpdoc_tool() {
    if [[ $(echo "$@" | grep -- '--all\|--phpdoc') ]]; then
        echo "- Updating PHPDocumentor"
        echo -n "  Old version: "
        phpdoc.phar --version 2> /dev/null || echo '0.0.0'
        echo "  average size ~33M (may take a while)"
        rm phpdoc.phar 2> /dev/null
        wget --quiet 'http://phpdoc.org/phpDocumentor.phar' -O phpdoc.phar
        chmod 755 phpdoc.phar
        echo -n "  New version: "
        ./phpdoc.phar --version 2> /dev/null || echo '0.0.0'
    fi
}

function update_phpcs_and_phpcbf_tool() {
    if [[ $(echo "$@" | grep -- '--all\|--phpcs\|--phpcbf') ]]; then
        if [[ $(which curl) ]]; then
            log_path='php_codesniffer.log'
            curl --silent --location 'https://github.com/squizlabs/PHP_CodeSniffer/releases/latest' > $log_path

            if [[ $(echo "$@" | grep -- '--phpcs') ]]; then
                echo "- Updating PHPCodeSniffer"
                phpcs_url=$(cat $log_path | grep 'phpcs\.phar" rel="nofollow"' | cut -d '"' -f 2)
                if [[ "$phpcs_url" != "" ]]; then
                    echo -n "  Old version: "
                    phpcs.phar --version 2> /dev/null || echo '0.0.0'
                    rm phpcs.phar 2> /dev/null
                    wget --quiet "https://github.com/${phpcs_url}" -O phpcs.phar
                    chmod 755 phpcs.phar
                    echo -n "  New version: "
                    ./phpcs.phar --version 2> /dev/null || echo '0.0.0'
                fi
            fi

            if [[ $(echo "$@" | grep -- '--phpcbf') ]]; then
                echo "- Updating PHPCodeSniffer Fixer"
                phpcbf_url=$(cat $log_path | grep 'phpcbf\.phar" rel="nofollow"' | cut -d '"' -f 2)
                if [[ "$phpcbf_url" != "" ]]; then
                    echo -n "  Old version: "
                    phpcbf.phar --version 2> /dev/null || echo '0.0.0'
                    rm phpcbf.phar 2> /dev/null
                    wget --quiet "https://github.com/${phpcbf_url}" -O phpcbf.phar
                    chmod 755 phpcbf.phar
                    echo -n "  New version: "
                    ./phpcbf.phar --version 2> /dev/null || echo '0.0.0'
                fi
            fi

            rm $log_path
        else
            echo "Error: Curl is required to update this tool"
            usage_options
            exit 1
        fi
    fi
}

function update_phploc_tool() {
    if [[ $(echo "$@" | grep -- '--all\|--phploc') ]]; then
        echo "- Updating PHPLOC (Lines Of Code)"
        echo -n "  Old version: "
        phploc.phar --version 2> /dev/null || echo '0.0.0'
        rm phploc.phar 2> /dev/null
        wget --quiet 'https://phar.phpunit.de/phploc.phar' -O phploc.phar
        chmod 755 phploc.phar
        echo -n "  New version: "
        ./phploc.phar --version 2> /dev/null || echo '0.0.0'
    fi
}

function update_phpcpd_tool() {
    if [[ $(echo "$@" | grep -- '--all\|--phpcpd') ]]; then
        echo "- Updating PHPCPD (Copy/Paste Detector)"
        echo -n "  Old version: "
        phpcpd.phar --version 2> /dev/null || echo '0.0.0'
        rm phpcpd.phar 2> /dev/null
        wget --quiet 'https://phar.phpunit.de/phpcpd.phar' -O phpcpd.phar
        chmod 755 phpcpd.phar
        echo -n "  New version: "
        ./phpcpd.phar --version 2> /dev/null || echo '0.0.0'
    fi
}

function update_phpmd_tool() {
    if [[ $(echo "$@" | grep -- '--all\|--phpmd') ]]; then
        echo "- Updating PHPMD (Mess Detector)"
        echo -n "  Old version: "
        phpmd.phar --version 2> /dev/null || echo '0.0.0'
        rm phpmd.phar 2> /dev/null
        wget --quiet 'http://static.phpmd.org/php/latest/phpmd.phar' -O phpmd.phar
        chmod 755 phpmd.phar
        echo -n "  New version: "
        ./phpmd.phar --version 2> /dev/null || echo '0.0.0'
    fi
}

function update_phpmetrics_tool() {
    if [[ $(echo "$@" | grep -- '--all\|--phpmetrics') ]]; then
        echo "- Updating PHP Metrics"
        echo -n "  Old version: "
        phpmetrics.phar --version 2> /dev/null || echo '0.0.0'
        rm phpmetrics.phar 2> /dev/null
        wget --quiet 'https://raw.githubusercontent.com/Halleck45/PhpMetrics/master/build/phpmetrics.phar' -O phpmetrics.phar
        chmod 755 phpmetrics.phar
        echo -n "  New version: "
        ./phpmetrics.phar --version 2> /dev/null || echo '0.0.0'
    fi
}

function update_wpcli_tool() {
    if [[ $(echo "$@" | grep -- '--all\|--wpcli') ]]; then
        echo "- Updating WordPress CLI"
        echo -n "  Old version: "
        wpcli.phar --version 2> /dev/null || echo '0.0.0'
        rm wpcli.phar 2> /dev/null
        wget --quiet 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar' -O wpcli.phar
        chmod 755 wpcli.phar
        echo -n "  New version: "
        ./wpcli.phar --version 2> /dev/null || echo '0.0.0'
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
        cd "${user_defined_target}"

        update_phpunit_tool "$@"
        update_phpdoc_tool "$@"
        update_phpcs_and_phpcbf_tool "$@"
        update_phploc_tool "$@"
        update_phpcpd_tool "$@"
        update_phpmd_tool "$@"
        update_phpmetrics_tool "$@"
        update_wpcli_tool "$@"

        echo "Finished"
        exit 0
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
