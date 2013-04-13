#!/usr/bin/env ruby
#
# Imgbox Downloader
# http://www.cixtor.com/
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
    puts '    http://www.cixtor.com/'
    puts '    https://github.com/cixtor/mamutools'
    puts '    http://imgbox.com/'
    puts
end
config = {
    :filename => __FILE__,
    :user_agent => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
    :album_id => nil
}
optparse = OptionParser.new do |option|
    option.banner = "Usage: #{config[:filename]} --id 'qqXcABLVX4'"
    option.on('-i arg', '--id=arg', 'Specify the gallery identifier (ten characters).'){ |arg| config[:album_id] = arg }
end
#
usage
begin
    optparse.parse!
    raise OptionParser::MissingArgument if config[:album_id].nil?
    #
    if match = config[:album_id].match(/imgbox\.com\/g\/([a-zA-Z0-9]{10})/) then
        config[:album_id] = match[1]
    elsif album_id.length > 10 then
        fail 'Error. Invalid album identifier.'
    end
    #
    if !config[:album_id].nil? then
        gallery_folder = "imgbox-#{config[:album_id]}"
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
        album_content = %x{curl --silent 'http://imgbox.com/g/#{config[:album_id]}'}
        album_lines = album_content.split("\n")
        album_lines.each do |line|
            if match = line.chomp.match(/<a href="\/(.*)" class="gallery_img"><img alt="(.*)" src="(.*)" \/><\/a>/) then
                image_content = %x{curl --silent --user-agent '#{config[:user_agent]}' 'http://imgbox.com/#{match[1]}'}
                image_lines = image_content.split("\n")
                image_lines.each do |image_line|
                    if image_match = image_line.chomp.match(/<img alt=".*" class="box" id="img" onclick=".*" src="(.*)" title="(.*)" \/>/) then
                        remote_image = image_match[1].gsub('&amp;', '&')
                        highlight "Downloading '#{remote_image}' as '#{image_match[2]}'"
                        %x{wget --quiet --user-agent='#{config[:user_agent]}' '#{remote_image}' -O '#{image_match[2]}'}
                    end
                end
            end
        end
        success 'Finished'
    end
rescue OptionParser::MissingArgument, OptionParser::InvalidOption
    p optparse
    fail "Process failed, #{$!.to_s}"
end
#
#