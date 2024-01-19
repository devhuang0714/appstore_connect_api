require_relative '../utils/easy_http'
require_relative 'generate_jwt_token'
require_relative 'models/bundle_ids_models'
require_relative 'option_parsers/bundle_ids_parser'

class BundleIDs
  # https://developer.apple.com/documentation/appstoreconnectapi/bundle_ids 
  
  def initialize(token)
    @token = token
    @headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@token}"
    }
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/register_a_new_bundle_id
  def register(bundle_id_create_request)
    url = 'https://api.appstoreconnect.apple.com/v1/bundleIds'
    body = bundle_id_create_request.to_hash.deep_compact
    EasyHTTP.post(url, @headers, body)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/modify_a_bundle_id
  def modify(id, bundle_id_update_request)
    url = "https://api.appstoreconnect.apple.com/v1/bundleIds/#{id}"
    body = bundle_id_update_request.to_hash.deep_compact
    EasyHTTP.patch(url, @headers, body)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/delete_a_bundle_id
  # response code: 204 success
  def delete(id)
    url = "https://api.appstoreconnect.apple.com/v1/bundleIds/#{id}"
    EasyHTTP.delete(url, @headers)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/list_bundle_ids
  def list(query = nil)
    url = 'https://api.appstoreconnect.apple.com/v1/bundleIds'
    EasyHTTP.get(url, @headers, query)
  end
  
  # https://developer.apple.com/documentation/appstoreconnectapi/read_bundle_id_information
  def info(id, query = nil)
    url = "https://api.appstoreconnect.apple.com/v1/bundleIds/#{id}"
    EasyHTTP.get(url, @headers, query)
  end

end

class TestBundleIds
  
  def initialize(token)
    @bundle_ids = BundleIDs.new(token)
  end

  def test_register
    json_string = <<~JSON 
    {
        "data": {
            "attributes": {
                "name": "test1",
                "identifier": "com.shangyewd.test1",
                "seedId": "Q7PV5K2Y9Y",
                "platform": "IOS"
            },
            "type": "bundleIds"
        }
    }
    JSON
    hash = JSON.parse(json_string)
    request = BundleIdCreateRequest.from_hash(hash)
    @bundle_ids.register(request)
  end

  def test_modify
    id = 'V932M5LP35' 
    query = {
      'filter[id]' => id
    }
    res = @bundle_ids.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first
      request_data = BundleIdUpdateRequest::Data.from_hash(data)
      request = BundleIdUpdateRequest.new(data: request_data)
      request.data.attributes.name = 'modifynametest'
      @bundle_ids.modify(id, request)
    end
  end

  def test_delete
    id = '2Z6GNN55X7'
    res = @bundle_ids.delete(id)
    if res.code == '204'
      puts "删除成功"
    end
  end

  def test_list
    @bundle_ids.list
  end

  def test_info
    id = '9LKTU7X7GW'
    @bundle_ids.info(id)
  end

end

if __FILE__ == $0
  main_parser = OptionParser.new do |opts|
    opts.banner = "Usage: appstore_connect_api.rb [options] [command [options]]"

    opts.on('-h', '--help', 'Show all commands, or show usage for a command.') do
      puts opts
      exit
    end
    
    opts.separator ''
    opts.separator 'commands:'

    BundleIdsParser.commands(opts)
  end

  main_parser.order!

  BundleIdsParser.parse_command(ARGV.first)
  #token = GenerateJWTToken.test_generate_token
  #test_bundle_ids = TestBundleIds.new(token)

  # 创建bundleID
  #test_bundle_ids.test_register

  # 修改bundleID
  #test_bundle_ids.test_modify

  #query = {
  #  'filter[identifier]': ['com.shangyewd.coupon']
  #}
  # 获取bundleID列表
  #test_bundle_ids.test_list(query)
  #test_bundle_ids.test_list

  # 获取某个bundleID详细信息
  #test_bundle_ids.test_info

  # 删除bundleID
  #test_bundle_ids.test_delete
end
