require 'json'
require 'optparse'
require_relative '../lib/option_parsers/generate_token_parser'
require_relative '../lib/option_parsers/beta_testers_parser'
require_relative '../lib/option_parsers/beta_groups_parser'
require_relative '../lib/option_parsers/bundle_ids_parser'
require_relative '../lib/option_parsers/certificates_parser'
require_relative '../lib/option_parsers/devices_parser'
require_relative '../lib/option_parsers/profiles_parser'
require_relative '../lib/option_parsers/users_parser'
#require_relative 'user_invations'

if __FILE__ == $0
  parsers = [
    GenerateTokenParser,
    BetaTestersParser,
    BetaGroupsParser,
    BundleIdsParser,
    CertificatesParser,
    DevicesParser,
    ProfilesParser,
    UsersParser
  ]
  main_parser = OptionParser.new do |opts|
    opts.banner = "Automate the tasks you perform on the Apple Developer website and in App Store Connect.\n\nUsage: appstore_connect_api.rb [options] [command [options]]"

    opts.on('-h', '--help', 'Show all commands, or show usage for a command.') do
      puts opts
      exit
    end
    
    parsers.each do |parser|
      if parser <= BaseParser
        parser.separator(opts)
        parser.commands(opts)
      end
    end
  end

  main_parser.order!

  command = ARGV.first
  parsers.each do |parser|
    if parser <= BaseParser
      if parser.parse_command(command) 
        exit
      end
    end
  end
  
  puts "Invalid command. Use 'appstore_connect_ipa.rb -h' for help."
end

