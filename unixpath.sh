#!/bin/bash
#
# UNIX Path
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/PATH_(variable)
#
# PATH is an environment variable on Unix-like operating systems, DOS, OS/2, and
# Microsoft Windows, specifying a set of directories where executable programs
# are located. In general, each executing process or user session has its own PATH
# setting.
#
# On POSIX and Unix-like operating systems, the $PATH variable is specified as
# a list of one or more directory names separated by colon (:) characters. The
# /bin, /usr/bin, and /usr/local/bin directories are typically included in most
# users' $PATH setting (although this varies from implementation to implementation).
# The current directory (.) is sometimes included as well, allowing programs
# residing in the current working directory to be executed directly. Superuser
# (root) accounts as a rule do not include it in $PATH, however, in order to
# prevent the accidental execution of scripts residing in the current directory.
# Executing such a program requires the deliberate use of a directory prefix
# (./) on the command name.
#
# When a command name is specified by the user or an exec call is made from a
# program, the system searches through $PATH, examining each directory from
# left to right in the list, looking for a filename that matches the command
# name. Once found, the program is executed as a child process of the command
# shell or program that issued the command.
#
IFS=':'
action=$1
function slogan {
    echo 'UNIX Path list'
    echo 'http://cixtor.com/'
    echo 'http://en.wikipedia.org/wiki/PATH_(variable)'
    echo
}
function help {
    slogan
    echo "Usage: $0 [action] [path]"
    echo '  -h | --help        Show this message with a list of allowed actions and options'
    echo '  -l | --list        Action to list all the paths registered in this session'
    echo '  -s | --search      Action to search a specific path among the registered locations'
    echo '  -a | --add         Action to add a new path to the user profile settings'
    exit 0
}
case "${action}" in
    -l|--list)
        slogan
        echo 'Listing paths'
        for path in $PATH; do echo "  ${path}"; done
        ;;
    -s|--search)
        echo 'Search path';;
    -a|--add)
        echo 'Adding path';;
    *)
        help;;
esac
#