require 'json'
require_relative 'base_parser'
require_relative '../beta_groups'

class BetaGroupsParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'Beta Groups commands:'
  end

  def self.commands(opts)
    opts.on('--beta-groups-list', 'Find and list beta groups for all apps.') do
      ARGV.unshift('beta-groups-list') 
    end
  end

  def self.parse_command(command)
    if command =~ /beta-groups-\w*/
      method_name = command.match(/beta-groups-(\w*)/)[1]
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

      opts.on('--filter-app FILTER_APP', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[app]'] = value
      end

      opts.on('--filter-builds FILTER_BUILDS', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[builds]'] = value
      end

      opts.on('--filter-id FILTER_ID', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[id]'] = value
      end

      opts.on('--filter-is-internal-group FILTER_IS_INTERNAL_GROUP', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[isInternalGroup]'] = value
      end

      opts.on('--filter-name FILTER_NAME', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[name]'] = value
      end

      opts.on('--filter-public-link PUBLIC_LINK', 'Attributes, relationships, and IDs by which to filter.') do |value|
        filter['filter[publicLink]'] = value
      end
      
      opts.on('--include INCLUDE', "Relationship data to include in the response.\nPossible Values: apps, betaTesters, builds") do |value|
        filter['include'] = value
      end

      opts.on('--limit LIMIT', "Number of resources to return.\nMaximum Value: 200") do |value|
        filter['limit'] = value
      end

      opts.on('--limit-beta-testers LIMIT_BETA_TESTERS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[betaTesters]'] = value
      end

      opts.on('--limit-builds LIMIT_BUILDS', "Number of included related resources to return.\nMaximum Value: 50") do |value|
        filter['limit[builds]'] = value
      end

      opts.on('--sort SORT', "Attributes by which to sort.\nPossible Values: createdDate, -createdDate, name, -name, publicLinkEnabled, -publicLinkEnabled, publicLinkLimit, -publicLinkLimit") do |value|
        filter['sort'] = value
      end
    end.order!
    
    if token.nil?
      puts 'token does not be nil'
      exit
    end

    beta_groups = BetaGroups.new(token)
    beta_groups.list(filter)
  end
end
