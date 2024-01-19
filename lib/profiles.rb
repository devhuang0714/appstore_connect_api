require 'base64'
require 'fileutils'
require_relative '../utils/easy_http'
require_relative 'generate_jwt_token'
require_relative 'models/profiles_models'
require_relative 'bundle_ids'
require_relative 'certificates'
require_relative 'devices'

class Profiles
  # https://developer.apple.com/documentation/appstoreconnectapi/create_a_profile

  def initialize(token)
    @token = token
    @headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@token}"
    }
  end

  # profileType: IOS_APP_DEVELOPMENT, IOS_APP_STORE, IOS_APP_ADHOC
  def create(profile_create_request)
    url ='https://api.appstoreconnect.apple.com/v1/profiles'
    body = profile_create_request.to_hash 
    EasyHTTP.post(url, @headers, body)
  end

  # response code: 204 success
  def delete(id)
    url = "https://api.appstoreconnect.apple.com/v1/profiles/#{id}"
    EasyHTTP.delete(url, @headers)
  end
  
  # https://developer.apple.com/documentation/appstoreconnectapi/list_and_download_profiles
  def list(query = nil)
    url = 'https://api.appstoreconnect.apple.com/v1/profiles'
    EasyHTTP.get(url, @headers, query)
  end

  def info(id)
    url = "https://api.appstoreconnect.apple.com/v1/profiles/#{id}"
    EasyHTTP.get(url, @headers)
  end

  def download(id, output_dir)
    res = info(id)
    if res.code == '200'
      data = JSON.parse(res.body)['data']
      profile_name = data['attributes']['name']
      profile_content = data['attributes']['profileContent']
      save_mobileprovision(profile_name, profile_content, output_dir)
    end
  end

  private 

  def save_mobileprovision(profile_name, profile_content, output_dir)
    begin
      # 解码字符串
      decoded_string = Base64.decode64(profile_content)

      FileUtils.mkdir_p(output_dir)
      file_path = "#{output_dir}/#{profile_name}.mobileprovision"
      # 保存（下载）描述文件
      File.open(file_path, 'w') do |file|
        file.puts decoded_string
        puts "Profile downloaded: #{file_path}"
      end
      
    rescue ArgumentError => e
      # 捕捉解码错误（无效的 Base64 编码）
      puts "Error decoding Base64: #{e.message}"
      
    rescue StandardError => e
      # 捕捉其他可能的错误
      puts "An unexpected error occurred: #{e.message}"
    end
  end

end

class TestProfiles
  
  def initialize(token)
    @token = token
    @profile = Profiles.new(@token)
  end

  def test_create_profile
    # 创建描述文件
    # 获取bundleID信息
    #bundle_ids = BundleIDs.new(token)
    #bundle_ids.list

    bundle_id_data = ProfileCreateRequest::Data::Relationships::Data.new(id: '2NAFSHQYHR', type: 'bundleIds')

    certs_data = []
    # 获取证书列表
    certs = Certificates.new(@token)
    query = {
      'filter[certificateType]' => 'DEVELOPMENT'
    }
    res = certs.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data']
      certs_data = data.map { |item| 
        ProfileCreateRequest::Data::Relationships::Data.new(id: item['id'], type: 'certificates')
      }
    end

    device_ids_data = []
    # 获取设备列表
    devices = Devices.new(@token)
    res = devices.list({ 'limit' => 200 })
    if res.code == '200'
      data = JSON.parse(res.body)['data']
      device_ids_data = data.map { |item|
        ProfileCreateRequest::Data::Relationships::Data.new(id: item['id'], type: 'devices')
      }
    end
    
    bundle_id = ProfileCreateRequest::Data::Relationships::BundleId.new(data: bundle_id_data)
    certificates = ProfileCreateRequest::Data::Relationships::Certificates.new(data: certs_data)
    devices = ProfileCreateRequest::Data::Relationships::Devices.new(data: device_ids_data)
    relationships = ProfileCreateRequest::Data::Relationships.new(bundleId: bundle_id, certificates: certificates, devices: devices)

    profile_name = '这是一个测试描述文件'
    profile_type = 'IOS_APP_DEVELOPMENT' # IOS_APP_DEVELOPMENT, IOS_APP_STORE, IOS_APP_ADHOC
    attributes = ProfileCreateRequest::Data::Attributes.new(name: profile_name, profileType: profile_type)

    request_data = ProfileCreateRequest::Data.new(attributes: attributes, relationships: relationships, type: 'profiles')
    request = ProfileCreateRequest.new(data: request_data)

    #puts bundle_id_data.to_hash
    #puts certs_data.to_hash
    #puts devices_data.to_hash
    puts request.to_hash

    res = @profile.create(request)
    if res.code == '201'
      puts "描述文件创建成功"
    end
  end

  def test_delete_profile
    id = 'JFU93B6DUS'
    res = @profile.delete(id)
    if res.code == '204'
      puts "描述文件删除成功"
    end
  end

  def test_list_profiles
    query = {
      'filter[name]' => '测试'
    }
    @profile.list(query)
  end
end

if __FILE__ == $0
  token = GenerateJWTToken.test_generate_token
  profile_test = TestProfiles.new(token)
  
  # 创建描述文件
  profile_test.test_create_profile

  # 删除描述文件
  #profile_test.test_delete_profile

  # 获取描述文件列表
  #profile_test.test_list_profiles
end
