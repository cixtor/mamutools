#!/usr/bin/env ruby
#
# Remote Assets
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
#
# List all the resources (assets) loaded in a specific page on a website.
#
# A digital asset is any item of text or media that has been formatted into a
# binary source that includes the right to use it. A digital file without the
# right to use it is not an asset. Digital assets are categorised in three major
# groups which may be defined as textual content (digital assets), images (media
# assets) and multimedia (media assets).
#
require 'rubygems'
require 'optparse'
require 'open-uri'
require 'uri'

config = Hash.new
optparse = OptionParser.new do |opt|
    opt.banner = "Usage: ruby #{opt.program_name} [OPTIONS]"
    opt.version = 1.0

    opt.on('-u', '--url args', 'Specify the remote location to scan.'){ |args| config[:target] = args }
    opt.on('-t', '--type args', 'Specify the filetype to look in the remote location specified.'){ |args| config[:filetype] = args }
    opt.on('-r', '--resource [images,javascript,styles]', 'Specify a group of filestypes to include in the scanning, for example, if you choose IMAGES it will search for the most common extensions: gif, jpg, png.'){ |args| config[:resource] = args }
    opt.on('-b', '--scanby [tag,extension]', 'Specify the type of scanning, you can choose between a scan using the tag architecture or using the extension of each file'){ |args| config[:scanby] = args }
end

begin
    optparse.parse!(ARGV)
    if config[:target].nil? then
        raise OptionParser::MissingArgument
    else
        config[:target] = "http://#{config[:target]}" if !config[:target].match(/^(http|https):\/\/.*/)
        config[:hostname] = URI.parse(config[:target]).host
        config[:scanby] = config[:scanby].nil? ? 'tag' : config[:scanby]

        filetypes = Array.new
        filetypes << config[:filetype] if !config[:filetype].nil?

        if filetypes.empty?
            raise OptionParser::MissingArgument
        else
            puts "\e[0;93mHostname:\e[0m #{config[:hostname]}"
            puts "\e[0;93mTarget:\e[0m #{config[:target]}"
            puts "\e[0;93mScan-by:\e[0m #{config[:scanby]}"
            puts "\e[0;93mExtensions:\e[0m #{filetypes.join(', ')}"
            puts '---------------'
            response = open(
                config[:target],
                'Referer'=>config[:hostname]
            )
            content = response.read

            puts "\e[0;93mResources found:\e[0m"
            if filetypes.empty? then
                puts "Filetypes empty."
            else
                lines = content.gsub("\"\n",'').gsub("\n",'').split('>')
                lines.each do |line|
                    if match = line.match(/<base href=.([a-zA-Z0-9:\.\-\/_ ]+)./) then
                        puts "\e[0;93mBase path:\e[0m #{match[1]}"
                    else
                        if !line.empty? then
                            line = "#{line.chomp}>"
                            regex = //
                            if config[:scanby] == 'tag' then
                                case config[:resource]
                                when 'images'
                                    regex = /<img.*src=.([a-zA-Z0-9=:\?\.\-\/_ ]+)..*>/
                                when 'javascript'
                                    regex = /<script.*src=.([a-zA-Z0-9=:\?\.\-\/_ ]+)..*>/
                                when 'styles'
                                    regex = /<link.*href=.([a-zA-Z0-9=:\?\.\-\/_ ]+)..*>/
                                end
                                if match = line.match(regex) then
                                    puts "  #{match[1]}"
                                end
                            elsif config[:scanby] == 'extension' then
                                filetypes.each do |filetype|
                                    if match = line.match(/(href|src)=.([a-zA-Z0-9=:\?\.\-\/_ ]+\.#{filetype}).( |>)/) then
                                        puts "  #{match[2]}"
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
rescue OptionParser::MissingArgument, OptionParser::InvalidOption
    puts optparse
    puts
    puts "\e[0;91mError.\e[0m Missing argument."
    # puts $!.to_s
end
