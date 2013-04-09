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
album_id = !ARGV[0].nil? ? ARGV[0].to_s : nil
user_agent = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'
#
if match = album_id.match(/imgbox\.com\/g\/([a-zA-Z0-9]{10})/) then
    album_id = match[1]
elsif album_id.length > 10 then
    album_id = nil
    puts "Error. Invalid album identifier."
end
if !album_id.nil? then
    album_content = %x{curl --silent 'http://imgbox.com/g/#{album_id}'}
    album_lines = album_content.split("\n")
    album_lines.each do |line|
        if match = line.chomp.match(/<a href="\/(.*)" class="gallery_img"><img alt="(.*)" src="(.*)" \/><\/a>/) then
            image_content = %x{curl --silent 'http://imgbox.com/#{match[1]}'}
            image_lines = image_content.split("\n")
            image_lines.each do |image_line|
                if image_match = image_line.chomp.match(/<img alt=".*" class="box" id="img" onclick=".*" src="(.*)" title="(.*)" \/>/) then
                    remote_image = image_match[1].gsub('&amp;', '&')
                    puts "Downloading '#{remote_image}' as '#{image_match[2]}'"
                    %x{wget --quiet --user-agent='#{user_agent}' '#{remote_image}' -O '#{image_match[2]}'}
                end
            end
        end
    end
end
#