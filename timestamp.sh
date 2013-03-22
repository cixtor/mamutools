#!/bin/bash
#
# UNIX Timestamp
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Unix_time
#
# Unix time, or POSIX time, is a system for describing instants in time, defined
# as the number of seconds that have elapsed since 00:00:00 Coordinated Universal
# Time (UTC), Thursday, 1 January 1970, not counting leap seconds. It is used
# widely in Unix-like and many other operating systems and file formats. Due to
# its handling of leap seconds, it is neither a linear representation of time nor
# a true representation of UTC. Unix time may be checked on some Unix systems by
# typing "date +%s" on the command line.
#
# Two layers of encoding make up Unix time. These can usefully be separated. The
# first layer encodes a point in time as a scalar real number, and the second
# encodes that number as a sequence of bits or in some other form.
#
# As is standard with UTC, this article labels days using the Gregorian calendar,
# and counts times within each day in hours, minutes, and seconds. Some of the
# examples also show International Atomic Time (TAI), another time scheme, which
# uses the same seconds and is displayed in the same format as UTC, but in which
# every day is exactly 86400 seconds long, gradually losing synchronization with
# the Earth's rotation at a rate of roughly one second per year.
#
date +%s
#