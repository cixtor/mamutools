#!/bin/bash
#
# DD File
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Dd_(Unix)
#
# DD (Data Description) is a command on Unix and Unix-like operating systems whose
# primary purpose is to convert and copy a file. On Unix, device drivers for
# hardware (such as hard disks) and special device files (such as /dev/zero and
# /dev/random) appear in the file system just like normal files; the command can
# also read and/or write from/to these files, provided that function is
# implemented in their respective driver. As a result, it can be used for tasks
# such as backing up the boot sector of a hard drive, and obtaining a fixed amount
# of random data. The program can also perform conversions on the data as it is
# copied, including byte order swapping and conversion to and from the ASCII and
# EBCDIC text encodings.
#

if [[ "${1}" =~ help ]]; then
    echo 'DD File'
    echo '  http://cixtor.com/'
    echo '  https://github.com/cixtor/mamutools'
    echo '  http://en.wikipedia.org/wiki/Dd_(Unix)'
    echo
    echo 'Description:'
    echo '  The command creates a zero-filled file named output.dat consisting of a count of'
    echo '  a number of blocks specified in the first argument, each of block size 1024, or'
    echo '  you can specify the size as a second argument.'
    echo
    echo 'Usage:'
    echo '  ddfile help     Prints this help message.'
    echo '  ddfile 10       Creates a file of 10 KB, each block is 1024 bs.'
    echo '  ddfile 10 1M    Creates a file of 10 MB, each block is 1 MB.'
    echo '  ddfile 30 1M    Creates a file of 30 MB, each block is 1 MB.'
fi
