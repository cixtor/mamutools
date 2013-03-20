#!/usr/bin/env ruby
#
# Follow Redirects
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
#
# The HTTP response status code '301 Moved Permanently' and '302 Moved Temporarily'
# are used for permanent redirection, meaning current links or records using the
# URL that the 301/302 response is received for should be updated to the new URL
# provided in the 'Location' field of the response. This status code should be used
# with the location header.
#
# RFC 2616 (http://tools.ietf.org/html/rfc2616) states that:
#   * If a client has link-editing capabilities, it should update all references to the Request URI.
#   * The response is cachable.
#   * Unless the request method was HEAD, the entity should contain a small hypertext note with a hyperlink to the new URI(s).
#   * If the 301 status code is received in response to a request of any type other than GET or HEAD, the client must ask the user before redirecting.
#
require 'rubygems'
require 'getoptlong'
#
def usage(message)
    puts "CURL URL Location"
    puts "Usage:"
    puts "  -h | --help  Display the available options."
    puts "  -u | --url   Specify the URL to send the HEAD request."
    puts
    puts message
    exit
end
def curl_head(location)
    redirect = false
    response = %x{curl -s --head '#{location}'}
    response.split("\n").each do |line|
        if match = line.match(/^Location: (.*)$/i) then
            redirect = true
            location = match[1].chomp
        end
    end
    if redirect===true
        puts "\e[0;93mRedirect:\e[0m #{location}"
        curl_head(location)
    else
        response.split("\n").each do |header|
            if header.chomp.match(/HTTP\/([0-9])\.([0-9])/) then
                puts "------------"
                puts "\e[0;92m#{header}\e[0m"
            else
                puts header
            end
        end
    end
end
#
location = nil
options = GetoptLong.new(
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    [ '--url', '-u', GetoptLong::REQUIRED_ARGUMENT ]
)
begin
    options.each do |opt, args|
        case opt
            when '--help'
                usage
            when '--url'
                location = args
            else
                raise('Invalid option')
        end
    end
    if location.nil?
        usage('Missing option, use --help to get a list of available options.')
    else
        puts "\e[0;92mOriginal:\e[0m #{location}"
        curl_head(location)
    end
rescue GetoptLong::InvalidOption => e
    puts "[+] Invalid option"
    usage
    exit
end
#