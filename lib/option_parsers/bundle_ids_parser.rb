require 'optparse'
require 'json'
require_relative 'base_parser'
require_relative '../bundle_ids'

class BundleIdsParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'Bundle IDs commands:'
  end

  def self.commands(opts)
    opts.on('--bundle-ids-register', 'Register a new bundle ID for app development.') do
      ARGV.unshift('bundle-ids-register')
    end

    opts.on('--bundle-ids-modify', 'Update a specific bundle ID’s name.') do
      ARGV.unshift('bundle-ids-modify') 
    end

    opts.on('--bundle-ids-delete', 'Delete a bundle ID that is used for app development.') do
      ARGV.unshift('bundle-ids-delete') 
    end

    opts.on('--bundle-ids-list', 'Find and list bundle IDs that are registered to your team.') do
      ARGV.unshift('bundle-ids-list') 
    end

    opts.on('--bundle-ids-info', 'Get information about a specific bundle ID.') do
      ARGV.unshift('bundle-ids-info') 
    end
  end

  def self.parse_command(command)
    if command =~ /bundle-ids-\w*/
      method_name = command.match(/bundle-ids-(\w*)/)[1]
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
      opts.banner = 'Usage: bundle-ids-register [options]'

      opts.on('-h', '--help', 'Display help for register tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('-n', '--name NAME', 'Bundle ID name') do |name|
        attributes_hash['name'] = name
      end

      opts.on('-i', '--identifier IDENTIFIER', 'Bundle ID identifier com.xxx.xxx') do |identifier|
        attributes_hash['identifier'] = identifier
      end
      
      opts.on('-p', '--platform [IOS|MAC_OS]', 'platform') do |platform|
        attributes_hash['platform'] = platform
      end

      opts.separator ''
      opts.separator 'Optional:'
      
      opts.on('-s', '--seedId SEED_ID', 'Bundle ID seedId') do |seedId|
        attributes_hash['seedId'] = seedId
      end
    end.order!
    
    if token.nil? || attributes_hash['name'].nil? || attributes_hash['identifier'].nil? || attributes_hash['platform'].nil?
      puts 'token, name, identifier and platform does not be nil'
      exit
    end

    attributes = BundleIdCreateRequest::Data::Attributes.from_hash(attributes_hash)
    data = BundleIdCreateRequest::Data.new(
      attributes: attributes,
      type: 'bundleIds'
    ) 
    request = BundleIdCreateRequest.new(
      data: data
    )
    bundle_ids = BundleIDs.new(token)
    bundle_ids.register(request)
  end

  def self.modify
    token, identifier, name = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: bundle-ids-modify [options]'

      opts.on('-h', '--help', 'Display help for modify tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'

      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('-i', '--identifier IDENTIFIER', 'Update identifier') do |value|
        identifier = value 
      end

      opts.on('-n', '--name NAME', 'Bundle ID name') do |value|
        name = value
      end
    end.order!
   
    if token.nil? || token.empty? || identifier.nil? || identifier.empty? || name.nil? || name.empty?
      puts 'token, identifier and name does not be nil'
      exit
    end

    bundle_ids = BundleIDs.new(token) 
    query = {
      'filter[identifier]' => identifier
    }
    res = bundle_ids.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first
      unless data.nil? || data.empty?
        id = data['id']
        request_data = BundleIdUpdateRequest::Data.from_hash(data)
        request = BundleIdUpdateRequest.new(
          data: request_data
        )
        request.data.attributes.name = name
        bundle_ids.modify(id, request)
      end
    end
  end

  def self.delete
    token, identifier = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: bundle-ids-delete [options]'

      opts.on('-h', '--help', 'Display help for delete tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'

      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('-i', '--identifier IDENTIFIER', 'Update identifier') do |value|
        identifier = value 
      end
    end.order!
   
    if token.nil? || token.empty? || identifier.nil? || identifier.empty? 
      puts 'token, identifier does not be nil'
      exit
    end

    bundle_ids = BundleIDs.new(token) 
    # 查找identifier的ID
    query = {
      'filter[identifier]' => identifier
    }
    res = bundle_ids.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first
      unless data.nil? || data.empty?
        id = data['id']
        bundle_ids.delete(id)
      end
    end
  end

  def self.list
    token = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: bundle-ids-list [options]'

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

      opts.on('--filter-bundleIds BUNDLE_IDS', '[string] Possible Values: app, bundleIdCapabilities, identifier, name, platform, profiles, seedId') do |bundle_ids|
        filter['filter[bundleIds]'] = bundle_ids
      end

      opts.on('--filter-profiles PROFILES', '[string] Possible Values: bundleId, certificates, createdDate, devices, expirationDate, name, platform, profileContent, profileState, profileType, uuid') do |profiles|
        filter['filter[profiles]'] = profiles
      end

      opts.on('--filter-id ID', 'Possible Values: bundleId, certificates, createdDate, devices, expirationDate, name, platform, profileContent, profileState, profileType, uuid') do |profiles|
        filter['filter[profiles]'] = profiles
      end

      opts.on('--filter-identifier IDENTIFIER', '[string]') do |value|
        filter['filter[identifier]'] = value
      end

      opts.on('--filter-name NAME', '[string]') do |value|
        filter['filter[name]'] = value
      end

      opts.on('--filter-platfrom PLATFORM', '[string] Possible Values: IOS, MAC_OS') do |value|
        filter['filter[platform]'] = value
      end

      opts.on('--filter-seedId SEED_ID', '[string]') do |value|
        filter['filter[seedId]'] = value
      end

      opts.on('--include INCLUDE', '[string] Possible Values: app, bundleIdCapabilities, profiles') do |value|
        filter['filter[include]'] = value
      end

      opts.on('--limit LIMIT', 'integer Maximum Value: 200') do |value|
        filter['limit'] = value
      end

      opts.on('--limit-profiles LIMIT_PROFILES', '[string] Maximum Value: 50') do |value|
        filter['limit[profiles]'] = value
      end

      opts.on('--sort SORT', '[string] Possible Values: id, -id, identifier, -identifier, name, -name, platform, -platform, seedId, -seedId') do |value|
        filter['sort'] = value
      end

      opts.on('--fields-bundle-id-capabilities FIELDS_BUNDLE_ID_CAPABILITIES', '[string] Possible Values: bundleId, capabilityType, settings') do |value|
        filter['fields[bundleIdCapabilities]'] = value
      end

      opts.on('--limit-bundle-id-capabilities LIMIT_BUNDLE_ID_CAPABILITIES', 'integer Maximum Value: 50') do |value|
        filter['limit[bundleIdCapabilities]'] = value
      end

      opts.on('--fields-apps FIELDS_APPS', '[string] Possible Values: appAvailability, appClips, appCustomProductPages, appEncryptionDeclarations, appEvents, appInfos, appPricePoints, appPriceSchedule, appStoreVersionExperimentsV2, appStoreVersions, availableInNewTerritories, availableTerritories, betaAppLocalizations, betaAppReviewDetail, betaGroups, betaLicenseAgreement, betaTesters, builds, bundleId, ciProduct, contentRightsDeclaration, customerReviews, endUserLicenseAgreement, gameCenterDetail, gameCenterEnabledVersions, inAppPurchases, inAppPurchasesV2, isOrEverWasMadeForKids, name, perfPowerMetrics, preOrder, preReleaseVersions, pricePoints, prices, primaryLocale, promotedPurchases, reviewSubmissions, sku, subscriptionGracePeriod, subscriptionGroups, subscriptionStatusUrl, subscriptionStatusUrlForSandbox, subscriptionStatusUrlVersion, subscriptionStatusUrlVersionForSandbox') do |value|
        filter['fields[apps]'] = value
      end
    end.order!
    
    if token.nil? || token.empty?
      puts "token does not be nil or empty"
      exit
    end

    bundle_ids = BundleIDs.new(token) 
    bundle_ids.list(filter)
  end

  def self.info
    identifier, token = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: bundle-ids-info [options]'

      opts.on('-h', '--help', 'Display help for infomation tool') do
        puts opts
        exit
      end
      
      opts.separator ''
      opts.separator 'Required:'

      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--identifier IDENTIFIER', 'Bundle ID identifier') do |value|
        identifier = value
      end

      opts.separator ''
      opts.separator 'Optional:'

      opts.on('--filter-bundleIds BUNDLE_IDS', '[string] Possible Values: app, bundleIdCapabilities, identifier, name, platform, profiles, seedId') do |bundle_ids|
        filter['filter[bundleIds]'] = bundle_ids
      end

      opts.on('--filter-profiles PROFILES', '[string] Possible Values: bundleId, certificates, createdDate, devices, expirationDate, name, platform, profileContent, profileState, profileType, uuid') do |profiles|
        filter['filter[profiles]'] = profiles
      end

      opts.on('--include INCLUDE', '[string] Possible Values: app, bundleIdCapabilities, profiles') do |value|
        filter['filter[include]'] = value
      end

      opts.on('--limit-profiles LIMIT_PROFILES', '[string] Maximum Value: 50') do |value|
        filter['limit[profiles]'] = value
      end

      opts.on('--fields-bundle-id-capabilities FIELDS_BUNDLE_ID_CAPABILITIES', '[string] Possible Values: bundleId, capabilityType, settings') do |value|
        filter['fields[bundleIdCapabilities]'] = value
      end

      opts.on('--limit-bundle-id-capabilities LIMIT_BUNDLE_ID_CAPABILITIES', 'integer Maximum Value: 50') do |value|
        filter['limit[bundleIdCapabilities]'] = value
      end

      opts.on('--fields-apps FIELDS_APPS', '[string] Possible Values: appAvailability, appClips, appCustomProductPages, appEncryptionDeclarations, appEvents, appInfos, appPricePoints, appPriceSchedule, appStoreVersionExperimentsV2, appStoreVersions, availableInNewTerritories, availableTerritories, betaAppLocalizations, betaAppReviewDetail, betaGroups, betaLicenseAgreement, betaTesters, builds, bundleId, ciProduct, contentRightsDeclaration, customerReviews, endUserLicenseAgreement, gameCenterDetail, gameCenterEnabledVersions, inAppPurchases, inAppPurchasesV2, isOrEverWasMadeForKids, name, perfPowerMetrics, preOrder, preReleaseVersions, pricePoints, prices, primaryLocale, promotedPurchases, reviewSubmissions, sku, subscriptionGracePeriod, subscriptionGroups, subscriptionStatusUrl, subscriptionStatusUrlForSandbox, subscriptionStatusUrlVersion, subscriptionStatusUrlVersionForSandbox') do |value|
        filter['fields[apps]'] = value
      end
    end.order!
    
    if token.nil? || token.empty? || identifier.nil? || identifier.empty?
      puts "token, identifier does not be nil or empty"
      exit
    end

    bundle_ids = BundleIDs.new(token) 
    query = {
      'filter[identifier]' => identifier
    }
    res = bundle_ids.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        bundle_ids.info(id, filter)
      end
    end
  end

end
