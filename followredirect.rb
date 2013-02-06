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