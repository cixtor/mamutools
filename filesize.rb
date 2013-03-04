#!/usr/bin/env ruby
#
# File Size
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/File_size
#
# File size measures the size of a computer file. Typically it is measured in
# bytes with a prefix. The actual amount of disk space consumed by the file
# depends on the file system. The maximum file size a file system supports
# depends on the number of bits reserved to store size information and the total
# size of the file system. For example, with FAT32, the size of one file cannot
# be equal or larger than 4 GiB.
#
# Some common file size units are:
#   1 byte = 8 bits
#   1 KiB = 1,024 bytes
#   1 MiB = 1,048,576 bytes
#   1 GiB = 1,073,741,824 bytes
#   1 TiB = 1,099,511,627,776 bytes
#
# Conversion Table
#   | Name      | Symbol | Binary Measurement | Decimal Measurement | Number of Bytes                   | Equal to
#   |-----------|--------|--------------------|---------------------|-----------------------------------|---------
#   | KiloByte  | KB     | 2 ^ 10             | 10 ^ 3              | 1,024                             | 1,024 B
#   | MegaByte  | MB     | 2 ^ 20             | 10 ^ 6              | 1,048,576                         | 1,024 KB
#   | GigaByte  | GB     | 2 ^ 30             | 10 ^ 9              | 1,073,741,824                     | 1,024 MB
#   | TeraByte  | TB     | 2 ^ 40             | 10 ^ 12             | 1,099,511,627,776                 | 1,024 GB
#   | PetaByte  | PB     | 2 ^ 50             | 10 ^ 15             | 1,125,899,906,842,624             | 1,024 TB
#   | ExaByte   | EB     | 2 ^ 60             | 10 ^ 18             | 1,152,921,504,606,846,976         | 1,024 PB
#   | ZettaByte | ZB     | 2 ^ 70             | 10 ^ 21             | 1,180,591,620,717,411,303,424     | 1,024 EB
#   | YottaByte | YB     | 2 ^ 80             | 10 ^ 24             | 1,208,925,819,614,629,174,706,176 | 1,024 ZB
#
def redirect(response)
    response.split("\n").each do |header|
        if match = header.match(/^Location: (.*)$/) then
            location = match[1].chomp
            # This concatenate with the response in the method RemoteSize
            print "\e[0;93mRedirect:\e[0m "
            file_size(location) and return
        end
    end
end
def readable_size(bytes, decimals=2)
    base = 1000 # List command in UNIX use 1000 instead of 1024
    sizes = 'BKMGTP'
    bytes = bytes.to_i
    factor = (("#{bytes}".size - 1)/3).to_f
    readable = sprintf( "%.#{decimals}f", bytes/(base**factor) )
    return "#{readable.to_s} #{sizes[factor]}"
end
def file_size(location)
    puts "\e[0;94m#{location}\e[0m"
    response = %x{curl --silent --head '#{location}'}
    response.split("\n").each do |header|
        header = header.chomp
        if match = header.match(/^HTTP\/([0-9]\.[0-9]) ([0-9]{3}) (.*)/) then
            if match[2].to_i == 200 then
                puts "\e[0;93mResponse:\e[0m \e[0;92m#{header}\e[0m"
            elsif ['301','302'].include?(match[2]) then
                redirect(response)
                exit
            else
                puts "\e[0;91m#{header}\e[0m" and exit
            end
        elsif match = header.match(/^Content-Type: (.*)$/) then
            puts "\e[0;93mContent-Type:\e[0m #{match[1]}"
        elsif match = header.match(/^Content-Length: (\d+)$/) then
            size = "#{match[1]}.0".to_f
            puts "\e[0;93mContent-Length:\e[0m #{size.round}"
            puts "\e[0;93mHuman-Size:\e[0m #{readable_size(size)}"
        end
    end
end
file_size( !ARGV[0].nil? ? ARGV[0] : '' )
#