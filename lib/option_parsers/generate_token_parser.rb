require 'optparse'
require_relative 'base_parser'
require_relative '../generate_jwt_token'

class GenerateTokenParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'Generate Token commands:'
  end

  def self.commands(opts)
    opts.on('--generate-token', 'Create JSON Web Tokens signed with your private key to authorize API requests.') do |value|
      ARGV.unshift('generate-token')
    end
  end

  def self.parse_command(command)
    if command == 'generate-token'
      ARGV.shift
      generate_token
      return true
    end

    false
  end

  def self.generate_token
    api_key_path, issuer_id, key_id, private_key = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: generate-token [options]'

      opts.on('-h', '--help', 'Show all commands, or show usage for a command.') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required Either:'

      opts.on('--api-key-path API_KEY_PATH', 'issuer_id, key_id, private_key json') do |value|
        api_key_path = value
      end

      opts.separator ''
      opts.separator 'Or:'

      opts.on('--issuer-id ISSUER_ID', 'App Store Connect API Issuer ID') do |value|
        issuer_id = value
      end
      
      opts.on('--key-id KEY_ID', 'App Store Connect API Key ID') do |value|
        key_id = value
      end

      opts.on('--private-key PRIVATE_KEY', 'App Store Connect API Private Key') do |value|
        private_key = value
      end
    end.order!

    if api_key_path && File.exist?(api_key_path)
      api_key = JSON.parse(File.read(api_key_path))
      issuer_id = api_key['issuer_id']
      key_id = api_key['key_id']
      private_key = api_key['private_key']
    end

    unless issuer_id && key_id && private_key
      puts 'issuer_id, key_id, private_key does not be nil'
      exit 
    end

    token = GenerateJWTToken.new(
      issuer_id: issuer_id,
      key_id: key_id,
      private_key: private_key
    ).token
    puts token
  end
end
