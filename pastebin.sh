#!/bin/bash
#
# Pastebin Tool
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Pastebin
#
# A Pastebin is a type of web application where anyone can store text for a
# certain period of time. This type of website is mainly used by programmers
# to store pieces of source code or configuration information, but anyone can
# basically share any type of text. The idea behind pastebins is to make it
# more convenient for people to share large amounts of text online.
#
# A vast number of pastebin related websites exist on the Internet, suiting
# a number of different needs and providing features tailored towards the
# crowd they focus on most.
#
# It took 8 years for Pastebin.com to surpass 10 million "Active" pastes (not
# spam or expired pastes). Less than a year later the owners of Pastebin.com
# tweeted that they had already surpassed the 20 million active pastes mark.
#
# In February 2010, Pastebin.com was sold by the original owner, Paul Dixon
# to Jeroen Vader, a Dutch serial Internet entrepreneur. Only a few weeks
# after the transfer, Mr. Vader had launched a whole new version of the
# website which he branded V2.0. In early 2011 V3.0 launched.
#
# There is some amount of controversy behind Pastebin.com due the spam like
# nature of a lot of the posts. Among other things, account passwords, credit
# card numbers, and other personal information is posted to Pastebin.com on
# a daily basis.
#
ID=$1
EXTENSION=$2
if [ "${EXTENSION}" == "--show" ]; then
	curl "http://pastebin.com/raw.php?i=${ID}"
else
	if [ "${EXTENSION}" != "" ]; then EXTENSION=".${EXTENSION}"; fi
	curl --silent "http://pastebin.com/raw.php?i=${ID}" > "${ID}${EXTENSION}"
fi
#