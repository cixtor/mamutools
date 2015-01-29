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

echo "Updating of PHP Phar files"
cd /opt/standalone/

echo "- Updating PHPUnit "
echo "  $(phpunit --version | tr -d '\n')"
rm phpunit.phar
wget --quiet 'https://phar.phpunit.de/phpunit.phar' -O phpunit.phar
echo "  $(phpunit --version | tr -d '\n')"

echo "- Updating PHPDocumentor"
echo "  $(phpdoc --version)"
echo "  average size ~33M (may take a while)"
rm phpdoc.phar
wget --quiet 'http://phpdoc.org/phpDocumentor.phar' -O phpdoc.phar
echo "  $(phpdoc --version)"

echo "Finished"
