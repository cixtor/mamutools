#!/usr/bin/env ruby
#
# Filename Formalizer
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Filename
#
# A filename (also written as two words, file name) is a name used to uniquely
# identify a computer file stored in a file system. Different file systems impose
# different restrictions on filename lengths and the allowed characters within
# filenames.
#
# A filename may include one or more of these components:
#   * host (or node or server) - network device that contains the file
#   * device (or drive) - hardware device or drive
#   * directory (or path) - directory tree (e.g., /usr/bin, \TEMP, [USR.LIB.SRC], etc.)
#   * file - base name of the file
#   * type (format or extension) - indicates the content type of the file (e.g., .txt, .exe, .COM, etc.)
#   * version - revision or generation number of the file
#
# The components required to identify a file varies across operating systems, as
# does the syntax and format for a valid filename. Within a single directory,
# filenames must be unique. Since the filename syntax also applies for directories,
# it is not possible to create a file and directory entries with the same name
# in a single directory. Multiple files in different directories may have the
# same name.
#
# Uniqueness approach may differ both on the case sensitivity and on the Unicode
# normalization form such as NFC, NFD. This means two separate files might be
# created with the same text filename and a different byte implementation of the
# filename, such as L"\x00C0.txt" (UTF-16, NFC) (Latin capital A with grave) and
# L"\x0041\x0300.txt" (UTF-16, NFD) (Latin capital A, grave combining).
#
# Some filesystems, such as FAT, store filenames as upper-case regardless of the
# letter case used to create them. For example, a file created with the name
# "MyName.Txt" or "myname.txt" would be stored with the filename "MYNAME.TXT".
# Any variation of upper and lower case can be used to refer to the same file.
# These kinds of file systems are called case-insensitive and are not case-
# preserving. Some filesystems prohibit the use of lower case letters in filenames
# altogether.
#
# Some file systems store filenames in the form that they were originally created;
# these are referred to as case-retentive or case-preserving. Such a file system
# can be case-sensitive or case-insensitive. If case-sensitive, then "MyName.Txt"
# and "myname.txt" may refer to two different files in the same directory, and each
# file must be referenced by the exact capitalisation by which it is named. On a
# case-insensitive, case-preserving file system, on the other hand, only one of
# "MyName.Txt", "myname.txt" and "Myname.TXT" can be the name of a file in a given
# directory at a given time, and a file with one of these names can be referenced
# by any capitalisation of the name.
#
# From its original inception, Unix and its derivative systems were case-preserving.
# However, not all Unix-like file systems are case-sensitive; by default, HFS+ in
# Mac OS X is case-insensitive, and SMB servers usually provide case-insensitive
# behavior (even when the underlying file system is case-sensitive, e.g. Samba on
# most Unix-like systems), and SMB client file systems provide case-insensitive
# behavior. File system case sensitivity is a considerable challenge for software
# such as Samba and Wine, which must interoperate efficiently with both systems
# that treat uppercase and lowercase files as different and with systems that treat
# them the same.
#
require 'rubygems'
require 'getoptlong'
#
config = {
    :action => false,
    :filename => nil,
    :rename => '',
    :batch => false
}
puts 'Filename Formalizer'
puts '  http://cixtor.com/'
puts '  https://github.com/cixtor/mamutools'
puts '  http://en.wikipedia.org/wiki/Filename'
puts
options = GetoptLong.new(
    [ '--action', '-a', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--filename', '-f', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--batch', '-b', GetoptLong::OPTIONAL_ARGUMENT ],
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)
begin
    options.each do |option, args|
        case option
            when '--action'
                config[:action] = args
            when '--filename'
                config[:filename] = args
            when '--batch'
                config[:batch] = true
            when '--help'
                puts "Usage:"
                puts "  Single action: #{__FILE__} -f 'filepath.ext' -a [dash|capitalize]"
                puts "  Batch mode...: #{__FILE__} -f 'filepath.ext' -a [dash|capitalize] -b"
                exit
        end
    end
rescue GetoptLong::InvalidOption => e
    puts "\e[0;91mError.\e[0m Invalid options, use --help to get a list of available options."
    exit
end
#
case config[:action]
    when 'capitalize'
        config[:rename] = config[:filename].split(/ /).map{ |w| w.downcase.capitalize }.join
    when 'dash'
        config[:rename] = config[:filename].downcase.gsub(' ','-')
end
if !config[:rename].empty? then
    puts "Rename '\e[0;94m#{config[:filename]}\e[0m' to '\e[0;93m#{config[:rename]}\e[0m'"
    if File.exists?(config[:rename]) then
        puts "\e[0;91mError.\e[0m The new filename already exists"
    else
        if config[:batch] then
            continue = 'y'
        else
            print "Do you want to continue? \e[0;93m(Y/n)\e[0m "
            continue = $stdin.gets.chomp
        end
        File.rename(config[:filename], config[:rename]) if continue.downcase=='y'
    end
else
    puts "\e[0;91mError.\e[0m the new filename is empty."
end
#