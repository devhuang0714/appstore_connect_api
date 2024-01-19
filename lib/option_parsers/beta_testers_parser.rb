require 'optparse'
require 'json'
require_relative 'base_parser'
require_relative '../beta_testers'

class BetaTestersParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'Beta Testers commands:'
  end

  def self.commands(opts)
    opts.on('--beta-testers-create', 'Create a beta tester assigned to a group, a build, or an app.') do
      ARGV.unshift('beta-testers-create')
    end

    opts.on('--beta-testers-delete', 'Remove a beta tester\'s ability to test all apps.') do
      ARGV.unshift('beta-testers-delete') 
    end

    opts.on('--beta-testers-list', 'Find and list beta testers for all apps, builds, and beta groups.') do
      ARGV.unshift('beta-testers-list') 
    end

    opts.on('--beta-testers-info', 'Get information about a specific bundle ID.') do
      ARGV.unshift('beta-testers-info') 
    end
  end

  def self.parse_command(command)
    if command =~ /beta-testers-\w*/
      method_name = command.match(/beta-testers-(\w*)/)[1]
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
    token, email, firstName, lastName = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: beta-testers-create [options]'

      opts.on('-h', '--help', 'Display help for create tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('-e', '--email EMAIL', 'Beta Tester email') do |value|
        email = value
      end

      opts.on('-f', '--first-name FIRST_NAME', 'Beta Tester first name') do |value|
        firstName = value
      end
      
      opts.on('-l', '--last-name LAST_NAME', 'Beta Tester last name') do |value|
        lastName = value
      end
    end.order!
    
    if token.nil? || email.nil? || firstName.nil? || lastName.nil?
      puts 'token, email, first-name and last-name does not be nil'
      exit
    end

    beta_groups_api = BetaGroups.new(token)
    res = beta_groups_api.list
    relationships = nil
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first
      betaGroups_data = BetaTesterCreateRequest::Data::Relationships::BetaGroups::Data.from_hash(data)
      betaGroups = BetaTesterCreateRequest::Data::Relationships::BetaGroups.new(data: [betaGroups_data]) 
      relationships = BetaTesterCreateRequest::Data::Relationships.new(betaGroups: betaGroups)
    end
    
    attributes = BetaTesterCreateRequest::Data::Attributes.new(
      email: email,
      firstName: firstName,
      lastName: lastName
    )
    request_data = BetaTesterCreateRequest::Data.new(
      attributes: attributes,
      relationships: relationships,
      type: 'betaTesters'
    )
    request = BetaTesterCreateRequest.new(data: request_data)

    beta_testers = BetaTesters.new(token)
    beta_testers.create(request)
  end

  def self.delete
    token, email = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: beta-testers-delete [options]'

      opts.on('-h', '--help', 'Display help for create tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('-e', '--email EMAIL', 'Beta Tester email') do |value|
        email = value
      end
    end.order!
    
    if token.nil? || email.nil? 
      puts 'token, email does not be nil'
      exit
    end

    beta_testers = BetaTesters.new(token)
    query = {
      'filter[email]' => email
    }
    res = beta_testers.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        devices.delete(id)
      end
    end
  end

  def self.list
    token = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: beta-testers-list [options]'

      opts.on('-h', '--help', 'Display help for create tool') do
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

      opts.on('--fields-beta-groups FIELDS_BETA_GROUPS', "Fields to return for included related types.\nPossible Values: app, betaTesters, builds, createdDate, feedbackEnabled, hasAccessToAllBuilds, iosBuildsAvailableForAppleSiliconMac, isInternalGroup, name, publicLink, publicLinkEnabled, publicLinkId, publicLinkLimit, publicLinkLimitEnabled") do |value|
        filter['fields[betaGroups]'] = value
      end

      opts.on('--fields-beta-testers FIELDS_BETA_TESTERS', "Fields to return for included related types.\nPossible Values: apps, betaGroups, builds, email, firstName, inviteType, lastName") do |value|
        filter['fields[betaTesters]'] = value
      end

      opts.on('--fields-builds FIELDS_BUILDS', "Fields to return for included related types.\nPossible Values: app, appEncryptionDeclaration, appStoreVersion, betaAppReviewSubmission, betaBuildLocalizations, betaGroups, buildAudienceType, buildBetaDetail, buildBundles, computedMinMacOsVersion, diagnosticSignatures, expirationDate, expired, iconAssetToken, icons, individualTesters, lsMinimumSystemVersion, minOsVersion, perfPowerMetrics, preReleaseVersion, processingState, uploadedDate, usesNonExemptEncryption, version") do |value|
        filter['fields[apps]'] = value
      end

      opts.on('--filter-beta-groups FILTER_BETA_GROUPS', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['fields[betaGroups]'] = value
      end

      opts.on('--filter-builds FILTER_BUILDS', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[builds]'] = value
      end

      opts.on('--filter-email FILTER_EMAIL', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[email]'] = value
      end

      opts.on('--filter-first-Name FILTER_FIRST_NAME', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[firstName]'] = value
      end

      opts.on('--filter-last-name FILTER_LAST_NAME', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[lastName]'] = value
      end

      opts.on('--filter-invite-type FILTER_INVITE_TYPE', "Attributes, relationships, and IDs by which to filter.\nPossible Values: EMAIL, PUBLIC_LINK") do |value|
        filter['filter[inviteType]'] = value
      end
      
      opts.on('--include INCLUDE', "Relationship data to include in the response.\nPossible Values: apps, betaGroups, builds") do |value|
        filter['include'] = value
      end

      opts.on('--limit LIMIT', "Number of resources to return.\nMaximum Value: 200") do |value|
        filter['limit'] = value
      end

      opts.on('--limit-apps LIMIT_APPS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[apps]'] = value
      end

      opts.on('--limit-beta-groups LIMIT_BETA_GROUPS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[betaGroups]'] = value
      end

      opts.on('--limit-builds LIMIT_BUILDS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[builds]'] = value
      end

      opts.on('--sort SORT', "Attributes by which to sort.\nPossible Values: email, -email, firstName, -firstName, inviteType, -inviteType, lastName, -lastName") do |value|
        filter['sort'] = value
      end

      opts.on('--filter-id FILTER_ID', "[string]") do |value|
        filter['filter[id]'] = value
      end
    end.order!
    
    if token.nil?
      puts 'token does not be nil'
      exit
    end

    beta_testers = BetaTesters.new(token)
    beta_testers.list(filter)
  end

  def self.info
    token, email = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: beta-testers-info [options]'

      opts.on('-h', '--help', 'Display help for create tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--email EMAIL', 'Beta Testers email') do |value|
        token = value
      end

      opts.separator ''
      opts.separator 'Optional:'
      
      opts.on('--fields-apps FIELDS_APPS', "Fields to return for included related types.\nPossible Values: appAvailability, appClips, appCustomProductPages, appEncryptionDeclarations, appEvents, appInfos, appPricePoints, appPriceSchedule, appStoreVersionExperimentsV2, appStoreVersions, availableInNewTerritories, availableTerritories, betaAppLocalizations, betaAppReviewDetail, betaGroups, betaLicenseAgreement, betaTesters, builds, bundleId, ciProduct, contentRightsDeclaration, customerReviews, endUserLicenseAgreement, gameCenterDetail, gameCenterEnabledVersions, inAppPurchases, inAppPurchasesV2, isOrEverWasMadeForKids, name, perfPowerMetrics, preOrder, preReleaseVersions, pricePoints, prices, primaryLocale, promotedPurchases, reviewSubmissions, sku, subscriptionGracePeriod, subscriptionGroups, subscriptionStatusUrl, subscriptionStatusUrlForSandbox, subscriptionStatusUrlVersion, subscriptionStatusUrlVersionForSandbox") do |value|
        filter['fields[apps]'] = value
      end

      opts.on('--fields-beta-groups FIELDS_BETA_GROUPS', "Fields to return for included related types.\nPossible Values: app, betaTesters, builds, createdDate, feedbackEnabled, hasAccessToAllBuilds, iosBuildsAvailableForAppleSiliconMac, isInternalGroup, name, publicLink, publicLinkEnabled, publicLinkId, publicLinkLimit, publicLinkLimitEnabled") do |value|
        filter['fields[betaGroups]'] = value
      end

      opts.on('--fields-beta-testers FIELDS_BETA_TESTERS', "Fields to return for included related types.\nPossible Values: apps, betaGroups, builds, email, firstName, inviteType, lastName") do |value|
        filter['fields[betaTesters]'] = value
      end

      opts.on('--fields-builds FIELDS_BUILDS', "Fields to return for included related types.\nPossible Values: app, appEncryptionDeclaration, appStoreVersion, betaAppReviewSubmission, betaBuildLocalizations, betaGroups, buildAudienceType, buildBetaDetail, buildBundles, computedMinMacOsVersion, diagnosticSignatures, expirationDate, expired, iconAssetToken, icons, individualTesters, lsMinimumSystemVersion, minOsVersion, perfPowerMetrics, preReleaseVersion, processingState, uploadedDate, usesNonExemptEncryption, version") do |value|
        filter['fields[apps]'] = value
      end

      opts.on('--include INCLUDE', "Relationship data to include in the response.\nPossible Values: apps, betaGroups, builds") do |value|
        filter['include'] = value
      end

      opts.on('--limit-apps LIMIT_APPS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[apps]'] = value
      end

      opts.on('--limit-beta-groups LIMIT_BETA_GROUPS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[betaGroups]'] = value
      end
    end.order!
    
    if token.nil? || email
      puts 'token, email does not be nil'
      exit
    end

    beta_testers = BetaTesters.new(token)
    res = beta_testers.list(filter)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        beta_testers.info(id, filter)
      end
    end
  end
end
