require 'net/http'
require 'uri'
require 'json'
require_relative 'generate_jwt_token'
require_relative 'models/devices_models'

class Devices
  # https://developer.apple.com/documentation/appstoreconnectapi/devices
  
  def initialize(token)
    @token = token
    @headers = {
      'Authorization' => "Bearer #{@token}",
      'Content-Type' => 'application/json'
    }
  end
 
  # https://developer.apple.com/documentation/appstoreconnectapi/register_a_new_device
  def register(device_create_request)
    url = 'https://api.appstoreconnect.apple.com/v1/devices'
    body = device_create_request.to_hash.deep_compact
    EasyHTTP.post(url, @headers, body)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/list_devices
  def list(query = nil)
    url = 'https://api.appstoreconnect.apple.com/v1/devices'
    EasyHTTP.get(url, @headers, query)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/read_device_information
  def info(id, query = nil)
    url = "https://api.appstoreconnect.apple.com/v1/devices/#{id}"
    EasyHTTP.get(url, @headers, query)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/modify_a_registered_device
  def modify(id, deivce_update_request)
    url = "https://api.appstoreconnect.apple.com/v1/devices/#{id}"
    body = device_update_request.to_hash.deep_compact
    EasyHTTP.patch(url, @headers, body)
  end

end

if __FILE__ == $0
  #token = GenerateJWTToken.test_generate_token
  # 有趣世界
  api_key = JSON.parse(File.read('tmp/api_key_yqsj.json'))
  generate_token = GenerateJWTToken.new(issuer_id: api_key['issuer_id'], key_id: api_key['key_id'], private_key: api_key['key'])
  token = generate_token.token
  device = Devices.new(token)

  # 注册一台设备
  #name = '季梦秋-自用机'
  #udid = '00008130-0004142C1A88001C'
  #attributes = DeviceCreateRequest::Data::Attributes.new(name: name, platform: 'IOS', udid: udid)
  #data = DeviceCreateRequest::Data.new(attributes: attributes)
  #request = DeviceCreateRequest.new(data: data)
  #res = device.register(request)
  #if res == '201'
  #  puts "设备添加成功"
  #end

  # 获取设备列表
  # 默认limit为20
  device.list

  # 获取所有设备
  #query = {
  #  'limit' => 200
  #}
  #device.list(query)

  # 获取设备信息
  #device.info('ZUZ7ZPX364')
end

