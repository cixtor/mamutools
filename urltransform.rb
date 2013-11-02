#!/usr/bin/env ruby
#
# URL Transform
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Percent-encoding
#
# Percent-encoding, also known as URL encoding, is a mechanism for encoding information
# in a Uniform Resource Identifier (URI) under certain circumstances. Although it is
# known as URL encoding it is, in fact, used more generally within the main Uniform
# Resource Identifier (URI) set, which includes both Uniform Resource Locator (URL)
# and Uniform Resource Name (URN). As such, it is also used in the preparation of
# data of the application/x-www-form-urlencoded media type, as is often used in the
# submission of HTML form data in HTTP requests.
#
# The characters allowed in a URI are either reserved or unreserved (or a percent
# character as part of a percent-encoding). Reserved characters are those characters
# that sometimes have special meaning. For example, forward slash characters are used
# to separate different parts of a URL (or more generally, a URI). Unreserved characters
# have no such meanings. Using percent-encoding, reserved characters are represented
# using special character sequences. The sets of reserved and unreserved characters and
# the circumstances under which certain reserved characters have special meaning have
# changed slightly with each revision of specifications that govern URIs and URI schemes.
#