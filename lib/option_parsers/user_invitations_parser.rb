require 'json'
require_relative 'base_parser'
require_relative '../user_invations'

class UserInvitationsParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'User Invitations commands:'
  end
  
  def self.commands(opts)
    opts.on('--user-invitations-list', 'Get a list of pending invitations to join your team.') do
      ARGV.unshift('user-invitations-list') 
    end

    opts.on('--user-invitations-info', 'Get information about a pending invitation to join your team.') do
      ARGV.unshift('user-invitations-info') 
    end

    opts.on('--user-invitations-invite', 'Invite a user with assigned user roles to join your team.') do
      ARGV.unshift('user-invitations-invite') 
    end

    opts.on('--user-invitations-cancel', 'Cancel a pending invitation for a user to join your team.') do
      ARGV.unshift('user-invitations-cancel') 
    end
  end

  def self.parse_command(command)
    if command =~ /user-invitations-\w*/
      method_name = command.match(/user-invitations-(\w*)/)[1]
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

  def self.list
    token = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: user-invitations-list [options]'

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
      
      opts.on('--fields-user-invitations FIELDS_USER_INVITATIONS', "Fields to return for included related types.\nPossible Values: allAppsVisible, email, expirationDate, firstName, lastName, provisioningAllowed, roles, visibleApps") do |value|
        filter['fields[userInvitations]'] = value
      end

      opts.on('--include INCLUDE', "Relationship data to include in the response.\nValue: visibleApps") do |value|
        filter['include'] = value
      end

      opts.on('--limit LIMIT', "Number of resources to return.\n Maximum Value: 200") do |value|
        filter['limit'] = value
      end

      opts.on('--sort SORT', "Attributes by which to sort.\nPossible Values: email, -email, lastName, -lastName") do |value|
        filter['sort'] = value
      end

      opts.on('--filter-roles FILTER_ROLES', "Attributes, relationships, and IDs by which to filter.\nPossible Values: ADMIN, FINANCE, ACCOUNT_HOLDER, SALES, MARKETING, APP_MANAGER, DEVELOPER, ACCESS_TO_REPORTS, CUSTOMER_SUPPORT, IMAGE_MANAGER, CREATE_APPS, CLOUD_MANAGED_DEVELOPER_ID, CLOUD_MANAGED_APP_DISTRIBUTION") do |value|
        filter['filter[roles]'] = value
      end

      opts.on('--filter-visible-apps FILTER_VISIBLE_APPS', "Attributes, relationships, and IDs by which to filter.") do |value|
        filter['filter[visibleApps]'] = value
      end

      opts.on('--filter-email FILTER_EMAIL', "Attributes, relationships, and IDs by which to filter.") do |value|
        filter['filter[email]'] = value
      end

      opts.on('--limit-visible-apps LIMIT_VISIBLE_APPS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[visibleApps]'] = value
      end
    end.order!
    
    if token.nil?
      puts 'token does not be nil'
      exit
    end
    
    user_invitations = UserInvitations.new(token)
    user_invitations.list(filter)
  end

  def self.info
    token, email = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: user-invitations-list [options]'

      opts.on('-h', '--help', 'Display help for info tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--email EMAIL', 'email') do |value|
        email = value
      end

      opts.separator ''
      opts.separator 'Optional:'
      
      opts.on('--fields-apps FIELDS_APPS', "Fields to return for included related types.\nPossible Values: appAvailability, appClips, appCustomProductPages, appEncryptionDeclarations, appEvents, appInfos, appPricePoints, appPriceSchedule, appStoreVersionExperimentsV2, appStoreVersions, availableInNewTerritories, availableTerritories, betaAppLocalizations, betaAppReviewDetail, betaGroups, betaLicenseAgreement, betaTesters, builds, bundleId, ciProduct, contentRightsDeclaration, customerReviews, endUserLicenseAgreement, gameCenterDetail, gameCenterEnabledVersions, inAppPurchases, inAppPurchasesV2, isOrEverWasMadeForKids, name, perfPowerMetrics, preOrder, preReleaseVersions, pricePoints, prices, primaryLocale, promotedPurchases, reviewSubmissions, sku, subscriptionGracePeriod, subscriptionGroups, subscriptionStatusUrl, subscriptionStatusUrlForSandbox, subscriptionStatusUrlVersion, subscriptionStatusUrlVersionForSandbox") do |value|
        filter['fields[apps]'] = value
      end
      
      opts.on('--fields-user-invitations FIELDS_USER_INVITATIONS', "Fields to return for included related types.\nPossible Values: allAppsVisible, email, expirationDate, firstName, lastName, provisioningAllowed, roles, visibleApps") do |value|
        filter['fields[userInvitations]'] = value
      end

      opts.on('--include INCLUDE', "Relationship data to include in the response.\nValue: visibleApps") do |value|
        filter['include'] = value
      end

      opts.on('--limit-visible-apps LIMIT_VISIBLE_APPS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[visibleApps]'] = value
      end
    end.order!
    
    if token.nil? || email.nil? 
      puts 'token, email does not be nil'
      exit
    end

    user_invitations = UserInvitations.new(token)
    query = {
      'filter[email]' => email
    }
    res = user_invitations.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        user_invitations.info(id)
      end
    end
  end

  def self.invite
    token, email, first_name, last_name, roles, all_apps_visible, provisioning_allowed = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: user-invitations-list [options]'

      opts.on('-h', '--help', 'Display help for info tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--email EMAIL', 'The email address of a pending user invitation. The email address must be valid to activate the account. It can be any email address, not necessarily one associated with an Apple ID.') do |value|
        email = value
      end

      opts.on('--first-name FIRST_NAME', 'The user invitation recipient\'s first name.
') do |value|
        first_name = value
      end

      opts.on('--last-name LAST_NAME', 'The user invitation recipient\'s last name.') do |value|
        last_name = value
      end

      opts.on('--roles ROLES', "Assigned user roles that determine the user's access to sections of App Store Connect and tasks they can perform.\nPossible Values: ACCESS_TO_REPORTS, ACCOUNT_HOLDER, ADMIN, APP_MANAGER, CLOUD_MANAGED_APP_DISTRIBUTION, CLOUD_MANAGED_DEVELOPER_ID, CREATE_APPS, CUSTOMER_SUPPORT, DEVELOPER, FINANCE, IMAGE_MANAGER, MARKETING, SALES") do |value|
        roles = value
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
          provisioning_allowed = true
        elsif value.downcase == 'false'
          provisioning_allowed = false
        end
      end
    end.order!
    
    if token.nil? || email.nil? || first_name.nil? || last_name.nil? || roles.nil?
      puts 'token, email does not be nil'
      exit
    end

    attributes = UserInvitationCreateRequest::Data::Attributes.new(
      email: email,
      firstName: first_name,
      lastName: last_name,
      roles: roles.split(','),
      allAppsVisible: all_apps_visible,
      provisioningAllowed: provisioning_allowed
    )
    relationships = UserInvitationCreateRequest::Data::Relationships.new(
      visibleApps: nil
    )
    data = UserInvitationCreateRequest::Data.new(
      attributes: attributes,
      relationships: nil,
      type: 'userInvitations'
    )
    request = UserInvitationCreateRequest.new(data: data)
    user_invitations = UserInvitations.new(token)
    user_invitations.invite(request)
  end

  def self.cancel
    token, email = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: user-invitations-list [options]'

      opts.on('-h', '--help', 'Display help for info tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--email EMAIL', 'email') do |value|
        email = value
      end
    end.order!
    
    if token.nil? || email.nil? 
      puts 'token, email does not be nil'
      exit
    end

    user_invitations = UserInvitations.new(token)
    query = {
      'filter[email]' => email
    }
    res = user_invitations.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        user_invitations.cancel(id)
      end
    end
  end
end
