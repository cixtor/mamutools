#!/usr/bin/env ruby
require 'rubygems'
require 'getoptlong'
#
opts = GetoptLong.new(
	[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
	[ '--length', '-l', GetoptLong::OPTIONAL_ARGUMENT ],
	[ '--count', '-c', GetoptLong::OPTIONAL_ARGUMENT ],
	[ '--all', '-a', GetoptLong::OPTIONAL_ARGUMENT ],
	[ '--type', '-t', GetoptLong::OPTIONAL_ARGUMENT ]
)
config = {
	:count => 1,
	:length => 10,
	:dictionary => Array.new,
	:types => {
		:alphabet_minus => ('a'..'z').to_a,
		:alphabet_mayus => ('A'..'Z').to_a,
		:numbers => (0..9).to_a.map(&:to_s),
		:specials => ('!@$%&*_+=-_?/.,:;#').split(//)
	}
}
#
force_dictionary = true
[ '-a', '--all', '-t', '--type' ].each do |opt|
	force_dictionary = false if ARGV.include?(opt)
end
ARGV << '--all' if force_dictionary
#
begin
	opts.each do |option, args|
		case option
			when '--help'
				puts "Password Generator"
				puts "Generate a specific list of random passwords with customizable length and types of characters."
				puts "------"
				puts "Usage:"
				puts "  -h | --help   = Print this message with the list of available options."
				puts "  -l | --length = Specify the length of each password. Default: 10"
				puts "  -c | --count  = Specify the quantity of passwords to generate. Default: 1"
				puts "  -t | --type   = Specify the type of characters to use, valid values are 'a, A, 1, @' you can combine them to add more characters like: 1a@"
				puts "  -a | --all    = Specify the use of all types of characters to generate passwors, same as: --type '1a@A'"
				exit
			when '--count'
				config[:count] = args.empty? ? config[:count] : args.to_i
			when '--length'
				config[:length] = args.empty? ? config[:length] : args.to_i
			when '--all'
				config[:dictionary] = Array.new
				config[:types].keys.each do |type|
					config[:dictionary] += config[:types][type]
				end
			when '--type'
				if config[:dictionary].empty? then
					if args.length==1 then
						config[:types].keys.each do |type|
							config[:dictionary] = config[:types][type] if config[:types][type].include?(args)
						end
					elsif args.length>1 then
						args.split(//).each do |char|
							config[:types].keys.each do |type|
								config[:dictionary] += config[:types][type] if config[:types][type].include?(char)
							end
						end
					else
						puts "The parameter '\e[1;92mType\e[0m' only accept one of these values: [\e[1;93m 1, a, A, @ \e[0m]"
						puts "or a combination of two or more of them, like this..: \e[1;93m-t a\e[0m OR \e[1;93m-t aA@\e[0m"
						exit
					end
				end
			else
				puts "Unknown option '#{option}' with this argument '#{args}'"
				exit
		end
	end
rescue GetoptLong::InvalidOption => e
	puts "\e[0;91m[!]\e[0m One or more options specified are invalid."
	puts "    Type: --help for a full list of valid options"
	exit(1)
end
#
chars = config[:dictionary]
config[:count].times do |index|
	puts Array.new(config[:length], '').collect{ chars[ rand(chars.size) ] }.join('')
end
#