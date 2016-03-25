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

FILEPATH="$1"
LINERANGE="$2"

if [[ "$FILEPATH" == "" ]] || [[ "$LINERANGE" == "" ]]; then
    echo "Print line number and ranges"
    echo "Usage: $0 [file] [x-y]"
    echo "  $0 /path/to/file.txt 10 # Prints only line #10 in file.txt"
    echo "  $0 /path/to/file.txt 3-10 # Prints lines 3 to 10 (inclusive)"
    exit 2
fi

RANGEA=$(echo "$LINERANGE" | cut -d '-' -f1)
RANGEB=$(echo "$LINERANGE" | cut -d '-' -f2)
ISRANGE=$([[ "$RANGEB" == "$RANGEA" ]] && echo "false" || echo "true")

# Print only the requested line.
if [[ "$ISRANGE" == "false" ]]; then
    head -n "$RANGEA" -- "$FILEPATH" | tail -n1
    exit $?
fi

# Print all lines between range A and B (inclusive).
OFFSET=$((RANGEB - RANGEA + 1)) # Spaces from file's tail.
head -n "$RANGEB" -- "$FILEPATH" | tail -n "$OFFSET"
exit $?
