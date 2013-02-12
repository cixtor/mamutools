#!/bin/bash
#
# Shortened Location
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/URL_shortening
#
# URL shortening is a technique on the WWW in which a Uniform Resource Locator
# may be made substantially shorter in length and still direct to the required
# page. This is achieved by using an HTTP Redirect on a domain name that is
# short, which links to the web page that has a long URL. For example:
# Target: http://en.wikipedia.org/wiki/URL_shortening
# Shortened:
#   http://bit.ly/urlwiki
#   http://tinyurl.com/urlwiki
#   http://is.gd/urlwiki
#   http://goo.gl/Gmzqv
#
# This is especially convenient for messaging technologies such as Twitter and
# Identi.ca which severely limit the number of characters that may be used in
# a message. Short URLs allow otherwise long web addresses to be referred to
# in a tweet. In November 2009, the shortened links of the URL shortening
# service Bitly were accessed 2.1 billion times.
#
# Other uses of URL shortening are to "beautify" a link, track clicks or disguise
# the underlying address. Although disguising of the underlying address may be
# desired for legitimate business or personal reasons, it is open to abuse and
# for this reason, some URL shortening service providers have found themselves
# on spam blacklists, because of the use of their redirect services by sites
# trying to bypass those very same blacklists. Some websites prevent short,
# redirected URLs from being posted.
#
URL=$1
if [[ $URL =~ ^http ]]; then
	curl --silent --head "${URL}" | grep '^Location: ' | head -n 1 | awk '{print $2}'
else
	echo -e "\e[0;91mError.\e[0m Malformed URL provided, use a valid URL."
fi
#