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
require 'cgi'
require 'open-uri'
require 'optparse'
#
options = Hash.new
optparse = OptionParser.new do |opt|
    opt.banner = "Usage: urltransform [options]"
    opt.on('-a action', '--action=action', 'Specify the action to perform with the given URL.'){ |args| options[:action] = args }
    opt.on('-u url', '--url=url', 'Specify the URL to check, when a Google URL is given, the redirection is returned.'){ |args| options[:url] = args }
end
begin
    optparse.parse!
    if ['encode','decode'].include?(options[:action]) then
        action = options[:action]
        if options[:url].nil? then
            raise OptionParser::MissingArgument, 'url'
        else
            string = options[:url]
            finalstr = "\e[0;92m%s\e[0m"
            if action == 'encode' then
                puts sprintf( finalstr, URI::encode(string) )
            elsif action == 'decode' then
                decoded = CGI::unescape(string)
                if match = decoded.match(/\.com\/url\?(.*)/) then
                    parts = match[1].split('&')
                    parts.each do |part|
                        if valid = part.match(/^url=(http.*)/) then
                            puts sprintf( finalstr, valid[1] )
                        end
                    end
                elsif match = decoded.match(/\.com.*imgrefurl=(.*)/) then
                    parts = match[1].split('?')
                    puts sprintf( finalstr, parts[0] )
                else
                    puts sprintf( finalstr, decoded )
                end
            end
        end
    else
        raise OptionParser::InvalidOption, 'Use --action=[encode|decode]'
    end
rescue OptionParser::MissingArgument, OptionParser::InvalidOption
    p optparse
    puts "\e[0;91m[x]\e[0m Process failed, #{$!.to_s}"
    exit(1)
end
#