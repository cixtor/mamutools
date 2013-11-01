#!/bin/bash
#
# Catline
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Cat_(Unix)
#
# The cat program is a standard Unix utility that concatenates and lists files. The
# name is an abbreviation of catenate, a synonym of concatenate. The Single Unix
# Specification specifies that when the "cat" program is given files in a sequence
# as arguments, it will output their contents to the standard output in the same
# sequence. It mandates the support of one option flag, u (unbuffered), by which
# each byte is written to standard output without buffering as it is read. Many
# operating systems do this by default and ignore the flag.
#
FILEPATH=$1
if [ "${FILEPATH}" != "" ]; then
    LINE=$2
    if [ "${LINE}" != "" ]; then
        if [[ "${LINE}" =~ ^[0-9]+$ ]]; then
            LENGTH=$3
            if ! [[ "${LENGTH}" =~ ^[0-9]+$ ]]; then
                LENGTH="";
                echo -e "\e[0;91mError.\e[0m The number of lines to show is not valid, you will see only one:"
            fi
            if [ "${LENGTH}" != "" ]; then
                head -n $(( $LINE + $LENGTH - 1 )) $FILEPATH | tail -n $LENGTH
            else
                head -n $LINE $FILEPATH | tail -n 1
            fi
        else
            echo -e "\e[0;91mError.\e[0m The line number specified is not numeric."
        fi
    else
        echo -e "\e[0;91mError.\e[0m You should specify a valid line number as the first parameter."
    fi
else
    echo -e "\e[0;91mError.\e[0m You should specify a valid file path."
fi
#