#!/bin/bash
#
# Source Code Management to Package
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Compression_program
#
# In computer science and information theory, data compression, source coding,
# or bit-rate reduction involves encoding information using fewer bits than the
# original representation. Compression can be either lossy or lossless. Lossless
# compression reduces bits by identifying and eliminating statistical redundancy.
# No information is lost in lossless compression. Lossy compression reduces bits
# by identifying unnecessary information and removing it. The process of reducing
# the size of a data file is popularly referred to as data compression, although
# its formal name is source coding (coding done at the source of the data before
# it is stored or transmitted).
#
# Compression is useful because it helps reduce resources usage, such as data
# storage space or transmission capacity. Because compressed data must be
# decompressed to use, this extra processing imposes computational or other costs
# through decompression; this situation is far from being a free lunch. Data
# compression is subject to a space-time complexity trade-off. For instance, a
# compression scheme for video may require expensive hardware for the video to be
# decompressed fast enough to be viewed as it is being decompressed, and the option
# to decompress the video in full before watching it may be inconvenient or require
# additional storage. The design of data compression schemes involves trade-offs
# among various factors, including the degree of compression, the amount of
# distortion introduced (e.g., when using lossy data compression), and the
# computational resources required to compress and uncompress the data.
#
# New alternatives to traditional systems (which sample at full resolution, then
# compress) provide efficient resource usage based on principles of compressed
# sensing. Compressed sensing techniques circumvent the need for data compression
# by sampling off on a cleverly selected basis.
#
SCM=$1
REPOSITORY=$2
#
function help {
	echo 'Source Code Management to Package'
	echo '  http://www.cixtor.com/'
	echo '  https://github.com/cixtor/mamutools'
	echo '  http://en.wikipedia.org/wiki/Compression_program'
	echo
	echo "Usage: $0 [git|hg|svn] [remote_repository]"
	echo
}
function fail {
	echo -e "\e[0;91m[x] Error.\e[0m ${1}"
	exit
}
function success {
	echo -e "\e[0;92mOK.\e[0m ${1}"
}
function question {
	echo -en "\e[0;94m[?]\e[0m ${1}"
}
#
help
if [ "${SCM}" == '' ]; then
	question "Which SCM do you want to use? (git, hg, svn): "
	read SCM_BINARY
	SCM=$SCM_BINARY
fi
if [ "${REPOSITORY}" == '' ]; then
	question "Specify the URL for the remote repository: "
	read REMOTE_REPOSITORY
	REPOSITORY=$REMOTE_REPOSITORY
fi
if [[ "${SCM}" =~ (git|hg|svn) ]]; then
	if [ $(which $SCM) ]; then
		if [ "${SCM}" == 'svn' ]; then PARAMETER='co'; else PARAMETER='clone'; fi
		$(which $SCM) $PARAMETER "${REPOSITORY}"
		FOLDERNAME=$(ls -1t | head -n 1)
		if [ -e "${FOLDERNAME}" ]; then
			PACKAGE="${FOLDERNAME}.tar.bz2"
			tar -c "${FOLDERNAME}" | bzip2 > "${PACKAGE}"
			if [ -e "${PACKAGE}" ]; then
				rm -rf "${FOLDERNAME}" && echo
				success "Package created at: \e[0;93m${PACKAGE}\e[0m"
			else
				fail "The package was not created, check manually to be sure."
			fi
		else
			fail "The cloned repository was not detected in the current page."
		fi
	else
		fail "The SCM '${SCM}' was not detected in your system path or it is not valid."
	fi
else
	fail "The SCM '${SCM}' is not supported."
fi
#