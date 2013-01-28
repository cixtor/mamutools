#!/bin/bash
#
# Massive Repository Pull
# http://www.cixtor.com/
# https://github.com/
#
# Being an autodidact developer I'm always looking new technologies to test out
# in my machine, counting new tools, languages and libraries. Almost sixty percent
# of all that information came to me in GIT Repositories, sometime ago I've created
# a script to clone those repositories mainly hosted on Github to compress those
# files in a BZip2 package, but then I wanted to have a tool to synchronize locally
# the latest version of some projects.
#
# Basically I used to execute the command git pull in many projects to get the latest
# version of some GIT Repository, but after some weeks that folder became tens of
# directories and obviously I don't want to waste my time checking manually all those
# repositories. I can write code, so I wrote a script to use in my crontab schedule
# and every week synchronize automatically all the changes in all the repositories,
# not only in my personal computer, but also in the servers I manage.
#
# 1. The script accept a unique parameter representing a location in the disk.
# 2. Check if the location provided is relative, in that case convert to an absolute path.
# 3. Find all the GIT Repositories in the absolute path specified.
# 4. Print the URL of the repository located generally in the file 'repository/.git/config'
# 5. Execute the command 'git pull' for each repository found.
#