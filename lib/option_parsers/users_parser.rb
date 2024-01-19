require 'json'
require_relative 'base_parser'
require_relative '../users'

class UsersParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'Users commands:'
  end
  
  def self.commands(opts)
    opts.on('--users-list', 'Get a list of the users on your team.') do
      ARGV.unshift('users-list') 
    end

    opts.on('--users-info', 'Get information about a user on your team, such as name, roles, and app visibility.') do
      ARGV.unshift('users-info') 
    end

    opts.on('--users-modify', 'Change a user\'s role, app visibility information, or other account details.') do
      ARGV.unshift('users-modify') 
    end

    opts.on('--users-remove', 'Remove a user from your team.') do
      ARGV.unshift('users-remove') 
    end
  end

  def self.parse_command(command)
    if command =~ /users-\w*/
      method_name = command.match(/users-(\w*)/)[1]
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

  def self.remove
    token, user_name = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: users-remove [options]'

      opts.on('-h', '--help', 'Display help for delete tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--username PROFILE_NAME', 'Profile name') do |value|
        user_name = value
      end
    end.order!
    
    if token.nil? || user_name.nil?
      puts 'token, username does not be nil'
      exit
    end

    users = Users.new(token)
    query = {
      'filter[username]' => user_name
    }
    res = users.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        users.delete(id)
      end
    end
  end

  def self.modify
    token, user_name, all_apps_visible, provisioning_allowed, roles = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: users-remove [options]'

      opts.on('-h', '--help', 'Display help for delete tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--username PROFILE_NAME', 'Profile name') do |value|
        user_name = value
      end

      opts.separator ''
      opts.separator 'Optional:'
      
      opts.on('--all-apps-visible ALL_APPS_VISIBLE', "Assigned user roles that determine the user's access to sections of App Store Connect and tasks they can perform.") do |value|
        if value.downcase == 'true'
          all_apps_visible = true
        elsif value.downcase == 'false'
          all_apps_visible = false
        end
      end

      opts.on('--provisioning-allowed PROVISIONING_ALLOWED', "A Boolean value that indicates the user's specified role allows access to the provisioning functionality on the Apple Developer website.") do |value|
        if value.downcase == 'true'
          provisioning_allowed  = true
        elsif value.downcase == 'false'
          provisioning_allowed = false
        end
      end

      opts.on('--roles ROLES', "Assigned user roles that determine the user's access to sections of App Store Connect and tasks they can perform.\nPossible Values: ACCESS_TO_REPORTS, ACCOUNT_HOLDER, ADMIN, APP_MANAGER, CLOUD_MANAGED_APP_DISTRIBUTION, CLOUD_MANAGED_DEVELOPER_ID, CREATE_APPS, CUSTOMER_SUPPORT, DEVELOPER, FINANCE, IMAGE_MANAGER, MARKETING, SALES") do |value|
        roles = value
      end
    end.order!
    
    if token.nil? || user_name.nil?
      puts 'token, username does not be nil'
      exit
    end

    users = Users.new(token)
    query = {
      'filter[username]' => user_name
    }
    res = users.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        data = JSON.parse(res.body)['data'].first
        request_data = UserUpdateRequest::Data.from_hash(data) 
        request = UserUpdateRequest.new(data: request_data)
        if all_apps_visible 
          request.data.attributes.allAppsVisible = all_apps_visible
        end
        if provisioning_allowed
          request.data.attributes.provisioningAllowed = provisioning_allowed
        end
        if roles
          request.data.attributes.roles = roles.split(',')
        end
        puts request.inspect
        users.modify(id, request)
      end
    end
  end

  def self.list
    token = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: users-list [options]'

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
      
      opts.on('--fields-apps FIELDS_APPS', "Fields to return for included related types.\nPossible Values: appAvailability, appClips, appCustomProductPages, appEncryptionDeclarations, appEvents, appInfos, appPricePoints, appPriceSchedule, appStoreVersionExperimentsV2, appStoreVersions, availableInNewTerritories, availableTerritories, betaAppLocalizations, betaAppReviewDetail, betaGroups, betaLicenseAgreement, betaTesters, builds, bundleId, ciProduct, contentRightsDeclaration, customerReviews, endUserLicenseAgreement, gameCenterDetail, gameCenterEnabledVersions, inAppPurchases, inAppPurchasesV2, isOrEverWasMadeForKids, name, perfPowerMetrics, preOrder, preReleaseVersions, pricePoints, prices, primaryLocale, promotedPurchases, reviewSubmissions, sku, subscriptionGracePeriod, subscriptionGroups, subscriptionStatusUrl, subscriptionStatusUrlForSandbox, subscriptionStatusUrlVersion, subscriptionStatusUrlVersionForSandbox") do |value|
        filter['fields[apps]'] = value
      end
      
      opts.on('--include INCLUDE', "Relationship data to include in the response.\nValue: visibleApps") do |value|
        filter['include'] = value
      end

      opts.on('--limit LIMIT', "Number of resources to return.\n Maximum Value: 200") do |value|
        filter['limit'] = value
      end

      opts.on('--sort SORT', "Attributes by which to sort.\nPossible Values: lastName, -lastName, username, -username") do |value|
        filter['sort'] = value
      end

      opts.on('--filter-roles FILTER_ROLES', "Attributes, relationships, and IDs by which to filter.\nPossible Values: ADMIN, FINANCE, ACCOUNT_HOLDER, SALES, MARKETING, APP_MANAGER, DEVELOPER, ACCESS_TO_REPORTS, CUSTOMER_SUPPORT, IMAGE_MANAGER, CREATE_APPS, CLOUD_MANAGED_DEVELOPER_ID, CLOUD_MANAGED_APP_DISTRIBUTION") do |value|
        filter['filter[roles]'] = value
      end

      opts.on('--filter-visible-apps FILTER_VISIBLE_APPS', "Attributes, relationships, and IDs by which to filter.") do |value|
        filter['filter[visibleApps]'] = value
      end

      opts.on('--filter-username FILTER_USERNAME', "Attributes, relationships, and IDs by which to filter.") do |value|
        filter['filter[username]'] = value
      end

      opts.on('--limit-visible-apps LIMIT_VISIBLE_APPS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[visibleApps]'] = value
      end
    end.order!
    
    if token.nil?
      puts 'token does not be nil'
      exit
    end
    
    users = Users.new(token)
    users.list(filter)
  end

  def self.info
    token, user_name = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: users-list [options]'

      opts.on('-h', '--help', 'Display help for info tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--username USER_NAME', 'email') do |value|
        user_name = value
      end
    end.order!
    
    if token.nil? || user_name.nil? 
      puts 'token, username does not be nil'
      exit
    end

    users = Users.new(token)
    query = {
      'filter[username]' => user_name
    }
    res = users.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        users.info(id)
      end
    end
  end
end
