require 'json'
require_relative 'base_parser'
require_relative '../profiles'

class ProfilesParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'Profiles commands:'
  end
  
  def self.commands(opts)
    opts.on('--profiles-create', 'Create a new provisioning profile.') do
      ARGV.unshift('profiles-create')
    end

    opts.on('--profiles-delete', 'Delete a provisioning profile that is used for app development or distribution.') do
      ARGV.unshift('profiles-delete') 
    end

    opts.on('--profiles-list', 'Find and list provisioning profiles and download their data.') do
      ARGV.unshift('profiles-list') 
    end

    opts.on('--profiles-info', 'Get information for a specific provisioning profile and download its data.') do
      ARGV.unshift('profiles-info') 
    end

    opts.on('--profiles-download', 'Download the provisioning profile data.') do
      ARGV.unshift('profiles-download') 
    end
  end

  def self.parse_command(command)
    if command =~ /profiles-\w*/
      method_name = command.match(/profiles-(\w*)/)[1]
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

  def self.create
    token, profile_name, profile_type, bundle_id, certificate_type = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: profiles-create [options]'

      opts.on('-h', '--help', 'Display help for create tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--profile-name PROFILE_NAME', 'string') do |value|
        profile_name = value
      end

      opts.on('--profile-type CERTIFICATE_TYPE', 'Possible Values: IOS_APP_DEVELOPMENT, IOS_APP_STORE, IOS_APP_ADHOC, IOS_APP_INHOUSE, MAC_APP_DEVELOPMENT, MAC_APP_STORE, MAC_APP_DIRECT, TVOS_APP_DEVELOPMENT, TVOS_APP_STORE, TVOS_APP_ADHOC, TVOS_APP_INHOUSE, MAC_CATALYST_APP_DEVELOPMENT, MAC_CATALYST_APP_STORE, MAC_CATALYST_APP_DIRECT') do |value|
        profile_type = value
      end

      opts.on('--bundle-id BUNDLE_ID', 'Bundle ID') do |value|
        bundle_id = value
      end

      opts.on('--certificate-type CERTIFICATE_TYPE', 'Possible Values: IOS_DEVELOPMENT, IOS_DISTRIBUTION, MAC_APP_DISTRIBUTION, MAC_INSTALLER_DISTRIBUTION, MAC_APP_DEVELOPMENT, DEVELOPER_ID_KEXT, DEVELOPER_ID_APPLICATION, DEVELOPMENT, DISTRIBUTION, PASS_TYPE_ID, PASS_TYPE_ID_WITH_NFC') do |value|
        certificate_type = value
      end
    end.order!
    
    if token.nil? || profile_name.nil? || profile_type.nil? || bundle_id.nil? || certificate_type.nil?
      puts 'token, profile-nam, profile-type, bundle-id, certificate-type does not be nil'
      exit
    end
    
    # 获取BundleID接口ID
    bundle_id_data = nil
    bundle_ids = BundleIDs.new(token)
    res = bundle_ids.list({
      'filter[identifier]' => bundle_id
    })
    if res.code == '200' 
      data = JSON.parse(res.body)['data'].first
      unless data.nil? || data.empty?
        id = data['id']
        bundle_id_data = ProfileCreateRequest::Data::Relationships::Data.new(id: id, type: 'bundleIds')
      else
        puts "#{bundle_id} not found"
        exit 1
      end
    end

    certs_data = []
    # 获取证书列表
    certs = Certificates.new(token)
    query = {
      'filter[certificateType]' => certificate_type
    }
    res = certs.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data']
      if data.nil? || data.empty?
        puts "Certificate list is empty"
        exit 1
      end
      
      certs_data = data.map { |item| 
        ProfileCreateRequest::Data::Relationships::Data.new(id: item['id'], type: 'certificates')
      }
    else 
      puts "get certificates list error: #{res.code}"
      exit 1
    end

    device_ids_data = []
    # 获取设备列表
    devices = Devices.new(token)
    res = devices.list({ 'limit' => 200 })
    if res.code == '200'
      data = JSON.parse(res.body)['data']
      if data.nil? || data.empty?
        puts "Device list is empty"
        exit 1
      end

      device_ids_data = data.map { |item|
        ProfileCreateRequest::Data::Relationships::Data.new(id: item['id'], type: 'devices')
      }
    else 
      puts "get devices list error: #{res.code}"
      exit 1
    end
    
    bundle_id = ProfileCreateRequest::Data::Relationships::BundleId.new(data: bundle_id_data)
    certificates = ProfileCreateRequest::Data::Relationships::Certificates.new(data: certs_data)
    devices = ProfileCreateRequest::Data::Relationships::Devices.new(data: device_ids_data)
    relationships = ProfileCreateRequest::Data::Relationships.new(bundleId: bundle_id, certificates: certificates, devices: devices)

    attributes = ProfileCreateRequest::Data::Attributes.new(name: profile_name, profileType: profile_type)

    request_data = ProfileCreateRequest::Data.new(attributes: attributes, relationships: relationships, type: 'profiles')
    request = ProfileCreateRequest.new(data: request_data)
    profiles = Profiles.new(token)
    profiles.create(request)
  end

  def self.delete
    token, profile_name, profile_type = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: profiles-delete [options]'

      opts.on('-h', '--help', 'Display help for delete tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--profile-name PROFILE_NAME', 'Profile name') do |value|
        profile_name = value
      end

      opts.on('--profile-type PROFILE_TYPE', 'Possible Values: IOS_APP_DEVELOPMENT, IOS_APP_STORE, IOS_APP_ADHOC, IOS_APP_INHOUSE, MAC_APP_DEVELOPMENT, MAC_APP_STORE, MAC_APP_DIRECT, TVOS_APP_DEVELOPMENT, TVOS_APP_STORE, TVOS_APP_ADHOC, TVOS_APP_INHOUSE, MAC_CATALYST_APP_DEVELOPMENT, MAC_CATALYST_APP_STORE, MAC_CATALYST_APP_DIRECT') do |value|
        profile_type = value
      end
    end.order!
    
    if token.nil? || profile_name.nil? || profile_type.nil?
      puts 'token, profile-name, profile-type does not be nil'
      exit
    end

    profiles = Profiles.new(token)
    query = {
      'filter[name]' => profile_name,
      'filter[profileType]' => profile_type
    }
    res = profiles.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        profiles.delete(id)
      end
    end
  end

  def self.list
    token = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: profiles-list [options]'

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
      
      opts.on('--fields-certificates FIELDS_CERTIFICATES', '[string] Possible Values: certificateContent, certificateType, csrContent, displayName, expirationDate, name, platform, serialNumber') do |value|
        filter['fields[certificates]'] = value
      end
      
      opts.on('--fields-devices FIELDS_DEVICES', '[string] Possible Values: addedDate, deviceClass, model, name, platform, status, udid') do |value|
        filter['filter[devices]'] = value
      end

      opts.on('--fields-profiles FIELDS_PROFILES', '[string] Possible Values: bundleId, certificates, createdDate, devices, expirationDate, name, platform, profileContent, profileState, profileType, uuid') do |value|
        filter['filter[profiles]'] = value
      end

      opts.on('--filter-id FILTER_ID', '[string]') do |value|
        filter['filter[id]'] = value
      end

      opts.on('--filter-name FILTER_NAME', '[string]') do |value|
        filter['filter[name]'] = value
      end

      opts.on('--include INCLUDE', '[string] Possible Values: bundleId, certificates, devices') do |value|
        filter['include'] = value
      end

      opts.on('--limit LIMIT', 'integer Maximum Value: 200') do |value|
        filter['limit'] = value
      end

      opts.on('--limit-certificates LIMIT_CERTIFICATES', 'integer Maximum Value: 50') do |value|
        filter['limit[certificates]'] = value
      end

      opts.on('--limit-devices LIMIT_DEVICES', 'integer Maximum Value: 50') do |value|
        filter['limit[devices]'] = value
      end

      opts.on('--fields-bundle-ids FIELDS_BUNDLE_IDS', '[string] Possible Values: app, bundleIdCapabilities, identifier, name, platform, profiles, seedId
') do |value|
        filter['fields[bundleIds]'] = value
      end

      opts.on('--filter-profile-state FILTER_PROFILE_STATE', '[string] Possible Values: ACTIVE, INVALID') do |value|
        filter['filter[profileState]'] = value
      end

      opts.on('--filter-profile-type FILTER_PROFILE_TYPE', '[string] Possible Values: IOS_APP_DEVELOPMENT, IOS_APP_STORE, IOS_APP_ADHOC, IOS_APP_INHOUSE, MAC_APP_DEVELOPMENT, MAC_APP_STORE, MAC_APP_DIRECT, TVOS_APP_DEVELOPMENT, TVOS_APP_STORE, TVOS_APP_ADHOC, TVOS_APP_INHOUSE, MAC_CATALYST_APP_DEVELOPMENT, MAC_CATALYST_APP_STORE, MAC_CATALYST_APP_DIRECT') do |value|
        filter['filter[profileType]'] = value
      end

    end.order!
    
    if token.nil?
      puts 'token does not be nil'
      exit
    end
    
    profiles = Profiles.new(token)
    profiles.list(filter)
  end

  def self.info
    token, profile_name, profile_type = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: profiles-list [options]'

      opts.on('-h', '--help', 'Display help for info tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--profile-name PROFILE_NAME', 'Profile name') do |value|
        profile_name = value
      end

      opts.on('--profile-type PROFILE_TYPE', 'Possible Values: IOS_APP_DEVELOPMENT, IOS_APP_STORE, IOS_APP_ADHOC, IOS_APP_INHOUSE, MAC_APP_DEVELOPMENT, MAC_APP_STORE, MAC_APP_DIRECT, TVOS_APP_DEVELOPMENT, TVOS_APP_STORE, TVOS_APP_ADHOC, TVOS_APP_INHOUSE, MAC_CATALYST_APP_DEVELOPMENT, MAC_CATALYST_APP_STORE, MAC_CATALYST_APP_DIRECT') do |value|
        profile_type = value
      end
    end.order!
    
    if token.nil? || profile_name.nil? || profile_type.nil?
      puts 'token, profile-name, profile-type does not be nil'
      exit
    end

    profiles = Profiles.new(token)
    query = {
      'filter[name]' => profile_name,
      'filter[profileType]' => profile_type
    }
    res = profiles.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        profiles.info(id)
      end
    end
  end
  
  def self.download
    token, profile_name, profile_type, output_directory = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: profiles-download [options]'

      opts.on('-h', '--help', 'Display help for download tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--profile-name PROFILE_NAME', 'Profile name') do |value|
        profile_name = value
      end

      opts.on('--profile-type PROFILE_TYPE', 'Possible Values: IOS_APP_DEVELOPMENT, IOS_APP_STORE, IOS_APP_ADHOC, IOS_APP_INHOUSE, MAC_APP_DEVELOPMENT, MAC_APP_STORE, MAC_APP_DIRECT, TVOS_APP_DEVELOPMENT, TVOS_APP_STORE, TVOS_APP_ADHOC, TVOS_APP_INHOUSE, MAC_CATALYST_APP_DEVELOPMENT, MAC_CATALYST_APP_STORE, MAC_CATALYST_APP_DIRECT') do |value|
        profile_type = value
      end
      
      opts.on('--output-directory OUTPUT_DIRECTORY', 'Profile download directory path') do |value|
        output_directory = value
      end
    end.order!
    
    if token.nil? || profile_name.nil? || profile_type.nil? || output_directory.nil?
      puts 'token, profile-name, profile-type, output-directory does not be nil'
      exit
    end

    profiles = Profiles.new(token)
    query = {
      'filter[name]' => profile_name,
      'filter[profileType]' => profile_type
    }
    res = profiles.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        profiles.download(id, output_directory)
      end
    end
  end
end
