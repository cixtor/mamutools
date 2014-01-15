#!/usr/bin/env ruby
#
# Remote Assets
# http://cixtor.com/
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

def random_agent
    user_agents = [
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)',
        'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)',
        'Googlebot/2.1 (http://www.googlebot.com/bot.html)',
        'Opera/9.20 (Windows NT 6.0; U; en)',
        'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.1) Gecko/20061205 Iceweasel/2.0.0.1 (Debian-2.0.0.1+dfsg-2)',
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; FDM; .NET CLR 2.0.50727; InfoPath.2; .NET CLR 1.1.4322)',
        'Opera/10.00 (X11; Linux i686; U; en) Presto/2.2.0',
        'Mozilla/5.0 (Windows; U; Windows NT 6.0; he-IL) AppleWebKit/528.16 (KHTML, like Gecko) Version/4.0 Safari/528.16',
        'Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)',
        'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.13) Gecko/20101209 Firefox/3.6.13',
        'Mozilla/4.0 (compatible; MSIE 9.0; Windows NT 5.1; Trident/5.0)',
        'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
        'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)',
        'Mozilla/4.0 (compatible; MSIE 6.0b; Windows 98)',
        'Mozilla/5.0 (Windows; U; Windows NT 6.1; ru; rv:1.9.2.3) Gecko/20100401 Firefox/4.0 (.NET CLR 3.5.30729)',
        'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.8) Gecko/20100804 Gentoo Firefox/3.6.8',
        'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.7) Gecko/20100809 Fedora/3.6.7-1.fc14 Firefox/3.6.7',
        'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
        'Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)',
        'YahooSeeker/1.2 (compatible; Mozilla 4.0; MSIE 5.5; yahooseeker at yahoo-inc dot com ; http://help.yahoo.com/help/us/shop/merchant/)'
    ]
    user_agents[rand(user_agents.size)]
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
        if !config[:resource].nil? then
            case config[:resource]
            when 'images'
                filetypes << 'gif'
                filetypes << 'jpg'
                filetypes << 'jpeg'
                filetypes << 'png'
                filetypes << 'svg'
            when 'javascript'
                filetypes << 'js'
                filetypes << 'coffee'
            when 'styles'
                filetypes << 'css'
                filetypes << 'sass'
                filetypes << 'less'
            end
        end

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
                'User-Agent'=>random_agent,
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
