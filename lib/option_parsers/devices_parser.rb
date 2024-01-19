require 'optparse'
require 'json'
require_relative 'base_parser'
require_relative '../devices'

class DevicesParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'Devices commands:'
  end
  
  def self.commands(opts)
    opts.on('--devices-register', 'Register a new device for app development.') do
      ARGV.unshift('devices-register')
    end

    opts.on('--devices-modify', 'Update the name or status of a specific device.') do
      ARGV.unshift('devices-modify') 
    end

    opts.on('--devices-list', 'Find and list devices registered to your team.') do
      ARGV.unshift('devices-list') 
    end

    opts.on('--devices-info', 'Get information for a specific device registered to your team.') do
      ARGV.unshift('devices-info') 
    end
  end

  def self.parse_command(command)
    if command =~ /devices-\w*/
      method_name = command.match(/devices-(\w*)/)[1]
      ARGV.shift 
      if self.respond_to?(method_name)
        self.send(method_name)
      else
        puts "#{self} does not respond to #{method_name}"
      end
      return true
    end

    false
  end

  def self.register
    token = nil
    attributes_hash = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: devices-register [options]'

      opts.on('-h', '--help', 'Display help for register tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('-n', '--name NAME', 'Devices name') do |value|
        attributes_hash['name'] = value
      end

      opts.on('-p', '--platform [IOS|MAC_OS]', 'platform') do |value|
        attributes_hash['platform'] = value
      end

      opts.on('-u', '--udid UDID', 'Devices UDID') do |value|
        attributes_hash['udid'] = value
      end
    end.order!
    
    if token.nil? || attributes_hash['name'].nil? || attributes_hash['udid'].nil? || attributes_hash['platform'].nil?
      puts 'token, name, udid and platform does not be nil'
      exit
    end

    attributes = DeviceCreateRequest::Data::Attributes.from_hash(attributes_hash)
    data = DeviceCreateRequest::Data.new(
      attributes: attributes,
      type: 'devices'
    ) 
    request = BundleIdCreateRequest.new(
      data: data
    )
    devices = Devices.new(token)
    devices.register(request)
  end

  def self.list
    token = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: devices-list [options]'

      opts.on('-h', '--help', 'Display help for list tool') do
        puts opts
        exit
      end
      
      opts.separator ''
      opts.separator 'Required:'

      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.separator ''
      opts.separator 'Optional:'

      opts.on('--filter-devices DEVICES', '[string] Possible Values: addedDate, deviceClass, model, name, platform, status, udid') do |value|
        filter['filter[devices]'] = value
      end

      opts.on('--filter-id ID', '[string]') do |value|
        filter['filter[id]'] = value
      end

      opts.on('--filter-name NAME', '[string]') do |value|
        filter['filter[name]'] = value
      end

      opts.on('--filter-platfrom PLATFORM', '[string] Possible Values: IOS, MAC_OS') do |value|
        filter['filter[platform]'] = value
      end

      opts.on('--filter-status STATUS', '[string] Possible Values: ENABLED, DISABLED, PROCESSING') do |value|
        filter['filter[status]'] = value
      end

      opts.on('--filter-udid UDID', '[string]') do |value|
        filter['filter[udid]'] = value
      end

      opts.on('--limit LIMIT', 'integer Maximum Value: 200') do |value|
        filter['limit'] = value
      end

      opts.on('--sort SORT', '[string] Possible Values: id, -id, name, -name, platform, -platform, status, -status, udid, -udid
') do |value|
        filter['sort'] = value
      end
    end.order!
    
    if token.nil? || token.empty?
      puts "token does not be nil or empty"
      exit
    end

    devices = Devices.new(token) 
    devices.list(filter)
  end

  def self.info
    token, udid = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: devices-info [options]'

      opts.on('-h', '--help', 'Display help for info tool') do
        puts opts
        exit
      end
      
      opts.separator ''
      opts.separator 'Required:'

      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--udid UDID', 'Devices UDID') do |value|
        udid = value
      end

      opts.separator ''
      opts.separator 'Optional:'

      opts.on('--filter-devices DEVICES', '[string] Possible Values: addedDate, deviceClass, model, name, platform, status, udid') do |value|
        filter['filter[devices]'] = value
      end
    end.order!
    
    if token.nil? || token.empty? || udid.nil? || udid.empty?
      puts "token, udid does not be nil or empty"
      exit
    end

    devices = Devices.new(token) 
    query = {
      'filter[udid]' => udid
    }
    res = devices.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        devices.info(id, filter)
      end
    end
  end

  def self.modify
    token, udid, name = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: devices-modify [options]'

      opts.on('-h', '--help', 'Display help for modify tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'

      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--udid UDID', 'Devices UDID') do |value|
        udid = value
      end

      opts.on('-n', '--name NAME', 'Devices name') do |value|
        name = value
      end
    end.order!
   
    if token.nil? || token.empty? || udid.nil? || udid.empty? || name.nil? || name.empty?
      puts 'token, udid and name does not be nil'
      exit
    end

    devices = Devices.new(token) 
    query = {
      'filter[udid]' => udid
    }
    res = devices.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        request_data = DeviceCreateRequest::Data.from_hash(data)
        request = DevicesUpdateRequest.new(
          data: data
        )
        request.data.attributes.name = name
        devices.modify(id, request)
      end
    end
  end
end
