#!/usr/bin/env ruby
#
# MD5 String
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/MD5
#
# Display the text string specified to MD5.
#
# The MD5 message-digest algorithm is a widely used cryptographic hash function
# producing a 128-bit (16-byte) hash value, typically expressed in text format
# as a 32 digit hexadecimal number. MD5 has been utilized in a wide variety of
# cryptographic applications, and is also commonly used to verify data integrity.
#
require 'digest'
string = ARGV.join(' ')
md5str = Digest::MD5.hexdigest(string)
puts "'#{string}' => #{md5str}"
