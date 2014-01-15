#!/usr/bin/env ruby
#
# Imgbox Downloader
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://imgbox.com/
#
# * What is imgbox?
#   Imgbox is a free image hosting service.
# * What file types are supported?
#   Images of the file types JPG, GIF and PNG are supported.
# * What is the maximum file size?
#   Each file must be 10MB or smaller.
# * How long are images stored?
#   Images are stored for life time (see our terms of service).
# * Should I keep a backup of my images on my local machine?
#   Yes, you always should backup your files.
# * I registered for a free account. How many images can I store?
#   There are no limits (fair use).
# * Can I inline link (hotlink) the original images I uploaded?
#   Yes, but please use the provided "full size" share codes only. Other URLs may change in the future.
# * Are there bandwidth limitations for inlin linking (hotlinking)?
#   There is no hard limit. Abusive referrers will be blocked.
# * Why are my thumbnail previews square?
#   Thumbnails on your "My Images" and "My Galleries" pages are displayed as squares to preserve the layout.
#
require 'optparse'
class Imgboxdown
    attr_reader :config, :optparse
    def initialize
        @config = {
            :filename => __FILE__,
            :user_agent => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
            :photo_id => nil,
            :gallery_id => nil
        }
        @optparse = OptionParser.new do |option|
            option.on('-i arg', '--id=arg', 'Specify the photo identifier.'){ |arg| config[:photo_id] = arg }
            option.on('-g arg', '--gallery=arg', 'Specify the gallery identifier.'){ |arg| config[:gallery_id] = arg }
        end
        usage
        execute
    end
    def success(message)
        puts "\e[0;92mOK.\e[0m #{message}"
    end
    def highlight(message)
        puts "\e[0;93m[>]\e[0m #{message}"
    end
    def fail(message)
        puts "\e[0;91m[x]\e[0m #{message}"
        exit(1)
    end
    def usage
        puts 'Imgbox Downloader'
        puts '    http://cixtor.com/'
        puts '    https://github.com/cixtor/mamutools'
        puts '    http://imgbox.com/'
        puts
    end
    def get_photo(photo_id, config)
        image_content = %x{curl --silent --user-agent '#{config[:user_agent]}' 'http://imgbox.com/#{photo_id}'}
        image_lines = image_content.split("\n")
        image_lines.each do |image_line|
            if image_match = image_line.chomp.match(/<img alt=".*" class="box" id="img" onclick=".*" src="(.*)" title="(.*)" \/>/) then
                remote_image = image_match[1].gsub('&amp;', '&')
                highlight "Downloading '#{remote_image}' as '#{image_match[2]}'"
                %x{wget --quiet --user-agent='#{config[:user_agent]}' '#{remote_image}' -O '#{image_match[2]}'}
            end
        end
    end
    def execute
        begin
            optparse.parse!
            if config[:photo_id].nil? and config[:gallery_id].nil? then
                raise OptionParser::MissingArgument
            end
            #
            if !config[:photo_id].nil? then
                get_photo(config[:photo_id], config)
            end
            #
            if !config[:gallery_id].nil? then
                gallery_folder = "imgbox-#{config[:gallery_id]}"
                if File.exists?(gallery_folder) then
                    success "Gallery folder already exists: \e[0;93m#{gallery_folder}\e[0m"
                else
                    if Dir.mkdir(gallery_folder) then
                        Dir.chdir(gallery_folder)
                        success "Gallery folder created: \e[0;93m#{gallery_folder}\e[0m"
                    else
                        fail "Could not create gallery folder: \e[0;93m#{gallery_folder}\e[0m"
                    end
                end
                #
                album_content = %x{curl --silent 'http://imgbox.com/g/#{config[:gallery_id]}'}
                album_lines = album_content.split("\n")
                album_lines.each do |line|
                    if match = line.chomp.match(/<a href="\/(.*)" class="gallery_img"><img alt="(.*)" src="(.*)" \/><\/a>/) then
                        get_photo(match[1], config)
                    end
                end
            end
            success 'Finished'
        rescue OptionParser::MissingArgument, OptionParser::InvalidOption
            p optparse
            fail "Process failed, #{$!.to_s}"
        end
    end
end
imgboxdown = Imgboxdown.new
#