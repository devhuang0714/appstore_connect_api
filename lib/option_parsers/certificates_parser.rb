require 'json'
require_relative 'base_parser'
require_relative '../certificates'

class CertificatesParser < BaseParser

  def self.separator(opts)
    opts.separator ''
    opts.separator 'Certificates commands:'
  end
  
  def self.commands(opts)
    opts.on('--certificates-create', 'Create a new certificate using a certificate signing request.') do
      ARGV.unshift('certificates-create')
    end

    opts.on('--certificates-list', 'Find and list certificates and download their data.') do
      ARGV.unshift('certificates-list') 
    end

    opts.on('--certificates-info', 'Get information about a certificate and download the certificate data.') do
      ARGV.unshift('certificates-info') 
    end

    opts.on('--certificates-revoke', 'Revoke a lost, stolen, compromised, or expiring signing certificate.') do
      ARGV.unshift('certificates-revoke') 
    end

    opts.on('--certificates-download', 'Download the certificate data.') do
      ARGV.unshift('certificates-download') 
    end
  end

  def self.parse_command(command)
    if command =~ /certificates-\w*/
      method_name = command.match(/certificates-(\w*)/)[1]
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
    token, certificate_type, csr_path = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: certificates-create [options]'

      opts.on('-h', '--help', 'Display help for create tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--certificate-type CERTIFICATE_TYPE', 'Possible Values: IOS_DEVELOPMENT, IOS_DISTRIBUTION, MAC_APP_DISTRIBUTION, MAC_INSTALLER_DISTRIBUTION, MAC_APP_DEVELOPMENT, DEVELOPER_ID_KEXT, DEVELOPER_ID_APPLICATION, DEVELOPMENT, DISTRIBUTION, PASS_TYPE_ID, PASS_TYPE_ID_WITH_NFC') do |value|
        certificate_type = value
      end

      opts.on('--csr-path CSR_PATH', 'Certificate Signing Request file path') do |value|
        csr_path = value
      end
    end.order!
    
    if token.nil? || certificate_type.nil? || csr_path.nil?
      puts 'token, certificate-type, csr-path does not be nil'
      exit
    end
    
    unless File.exist?(csr_path)
      puts "#{csr_path} does not exist"
      exit 1
    end

    cert_signing_request = File.read(csr_path)
    matches = cert_signing_request.match(/-----BEGIN CERTIFICATE REQUEST-----(.*?)-----END CERTIFICATE REQUEST-----/m)
    if matches
      csr_content = matches[1].gsub(/\s+/, '') #去除换行符
      attributes = CertifiateCreateRequest::Data::Attributes.new(
        certificateType: certificate_type, 
        csrContent: csr_content
      )
      data = CertifiateCreateRequest::Data.new(
        attributes: attributes, 
        type: 'certificates'
      )
      request = CertifiateCreateRequest.new(
        data: data
      )
      certs = Certificates.new(token)
      certs.create(request)
    end
  end

  def self.list
    token = nil
    filter = {}
    OptionParser.new do |opts|
      opts.banner = 'Usage: certificates-list [options]'

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
      
      opts.on('--filter-id FILTER_ID', '[string]') do |value|
        filter['filter[id]'] = value
      end

      opts.on('--filter-serial-number FILTER_SERIAL_NUMBER', '[string]') do |value|
        filter['filter[serialNumber]'] = value
      end

      opts.on('--limit LIMIT', 'integer Maximum Value: 200') do |value|
        filter['limit'] = value
      end

      opts.on('--sort SORT', '[string] Possible Values: certificateType, -certificateType, displayName, -displayName, id, -id, serialNumber, -serialNumber') do |value|
        filter['sort'] = value
      end

      opts.on('--certificate-type CERTIFICATE_TYPE', 'Possible Values: IOS_DEVELOPMENT, IOS_DISTRIBUTION, MAC_APP_DISTRIBUTION, MAC_INSTALLER_DISTRIBUTION, MAC_APP_DEVELOPMENT, DEVELOPER_ID_KEXT, DEVELOPER_ID_APPLICATION, DEVELOPMENT, DISTRIBUTION, PASS_TYPE_ID, PASS_TYPE_ID_WITH_NFC') do |value|
        filter['filter[certificateType]'] = value
      end

      opts.on('--filter-display-name FILTER_DISPLAY_NAME', '[string]') do |value|
        filter['filter[displayName]'] = value
      end
    end.order!
    
    if token.nil?
      puts 'token does not be nil'
      exit
    end
    
    certs = Certificates.new(token)
    certs.list(filter)
  end

  def self.info
    token, display_name, certificate_type = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: certificates-list [options]'

      opts.on('-h', '--help', 'Display help for list tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--display-name DISPLAY_NAME', 'Certificate Display Name') do |value|
        display_name = value
      end

      opts.on('--certificate-type CERTIFICATE_TYPE', 'Possible Values: IOS_DEVELOPMENT, IOS_DISTRIBUTION, MAC_APP_DISTRIBUTION, MAC_INSTALLER_DISTRIBUTION, MAC_APP_DEVELOPMENT, DEVELOPER_ID_KEXT, DEVELOPER_ID_APPLICATION, DEVELOPMENT, DISTRIBUTION, PASS_TYPE_ID, PASS_TYPE_ID_WITH_NFC') do |value|
        certificate_type = value
      end
    end.order!
    
    if token.nil? || display_name.nil? || certificate_type.nil?
      puts 'token, display-name, certificate-name does not be nil'
      exit
    end

    certs = Certificates.new(token)
    query = {
      'filter[displayName]' => display_name,
      'filter[certificateType]' => certificate_type
    }
    res = certs.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        certs.info(id)
      end
    end
  end
  
  def self.revoke
    token, display_name, certificate_type = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: certificates-list [options]'

      opts.on('-h', '--help', 'Display help for list tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--display-name DISPLAY_NAME', 'Certificate Display Name') do |value|
        display_name = value
      end

      opts.on('--certificate-type CERTIFICATE_TYPE', 'Possible Values: IOS_DEVELOPMENT, IOS_DISTRIBUTION, MAC_APP_DISTRIBUTION, MAC_INSTALLER_DISTRIBUTION, MAC_APP_DEVELOPMENT, DEVELOPER_ID_KEXT, DEVELOPER_ID_APPLICATION, DEVELOPMENT, DISTRIBUTION, PASS_TYPE_ID, PASS_TYPE_ID_WITH_NFC') do |value|
        certificate_type = value
      end
    end.order!
    
    if token.nil? || display_name.nil? || certificate_type.nil?
      puts 'token, display-name, certificate-name does not be nil'
      exit
    end

    certs = Certificates.new(token)
    query = {
      'filter[displayName]' => display_name,
      'filter[certificateType]' => certificate_type
    }
    res = certs.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty? || data['attributes'].nil?
        display_name = data['attributes']['displayName']
        if display_name == certificate_name
          id = data['id']
          certs.revoke(id)
        end
      end
    end
  end

  def self.download
    token, display_name, certificate_type, output_directory = nil
    OptionParser.new do |opts|
      opts.banner = 'Usage: certificates-list [options]'

      opts.on('-h', '--help', 'Display help for list tool') do
        puts opts
        exit
      end

      opts.separator ''
      opts.separator 'Required:'
      
      opts.on('--token TOKEN', 'App Store Connect API Token') do |value|
        token = value
      end

      opts.on('--display-name DISPLAY_NAME', 'Certificate Display Name') do |value|
        display_name = value
      end

      opts.on('--certificate-type CERTIFICATE_TYPE', 'Possible Values: IOS_DEVELOPMENT, IOS_DISTRIBUTION, MAC_APP_DISTRIBUTION, MAC_INSTALLER_DISTRIBUTION, MAC_APP_DEVELOPMENT, DEVELOPER_ID_KEXT, DEVELOPER_ID_APPLICATION, DEVELOPMENT, DISTRIBUTION, PASS_TYPE_ID, PASS_TYPE_ID_WITH_NFC') do |value|
        certificate_type = value
      end
      
      opts.on('--output-directory OUTPUT_DIRECTORY', 'Certificate download directory path') do |value|
        output_directory = value
      end
    end.order!
    
    if token.nil? || display_name.nil? || certificate_type.nil? || output_directory.nil?
      puts 'token, display-name, certificate-name, output-directory does not be nil'
      exit
    end

    certs = Certificates.new(token)
    query = {
      'filter[displayName]' => display_name,
      'filter[certificateType]' => certificate_type
    }
    res = certs.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first 
      unless data.nil? || data.empty?
        id = data['id']
        certs.download(id, output_directory)
      end
    end
  end
end
