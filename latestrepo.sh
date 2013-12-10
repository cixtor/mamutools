#!/bin/bash
#
# Latest Repository Downloader
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
#
# Sometime ago I wrote a Script to fetch dynamically multiple GIT repositories at
# once and now I have a folder with several folders sizing more than 20 GB, so I
# decided to write a different tool to do the same thing (fetch an remote repository)
# but instead of maintain the commit history I will automatically remove the ".git"
# folder once the code is downloaded and rename the configuration file containing
# the URL of the repository in a different path so when I execute the script again
# inside that folder it should detect automatically that it is a GIT repository but
# containing just the latest version of the code. That way I can update the code
# whenever I want and decrease the quantity of disk needed to store those projects.
#