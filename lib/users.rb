require 'json'
require_relative '../utils/easy_http'
require_relative 'generate_jwt_token'
require_relative 'models/users_models'

class Users
  # https://developer.apple.com/documentation/appstoreconnectapi/users

  def initialize(token)
    @token = token
    @headers = {
      'Authorization' => "Bearer #{@token}",
      'Content-Type' => 'application/json'
    }
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/list_users
  def list(query = nil)
    url = 'https://api.appstoreconnect.apple.com/v1/users'
    EasyHTTP.get(url, @headers, query)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/read_user_information
  def info(id, query = nil)
    url = "https://api.appstoreconnect.apple.com/v1/users/#{id}"
    EasyHTTP.get(url, @headers, query)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/modify_a_user_account
  def modify(id, user_update_request)
    url = "https://api.appstoreconnect.apple.com/v1/users/#{id}"
    body = user_update_request.to_hash.deep_compact
    EasyHTTP.patch(url, @headers, body)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/remove_a_user_account
  # response code: 204 success
  def remove(id)
    url = "https://api.appstoreconnect.apple.com/v1/users/#{id}"
    EasyHTTP.delete(url, @headers)
  end

end

class TestUsers
  
  def initialize(token)
    @users = Users.new(token)
  end

  def test_list
    @users.list
    #query = {
    #  'filter[username]' => 'hytest2020@yeah.net'
    #}
    #@users.list(query)
  end

  def test_modify
    query = {
      'filter[username]' => 'hytest2020@yeah.net'
    }
    res = @users.list(query)
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first
      request_data = UserUpdateRequest::Data.from_hash(data) 
      request = UserUpdateRequest.new(data: request_data)
      request.data.attributes.roles = [UserRole::MARKETING]
      puts request.inspect
      res = @users.modify(request.data.id, request)
      if res.code == '200'
        puts "用户修改成功"
      end
    end
  end

  def test_remove
    id = '2824b376-6107-4f48-8e59-c1ee96c80f84'
    res = @users.remove(id)
    if res.code == '204'
      puts "移除成功"
    end
  end
end

if __FILE__ == $0
  token = GenerateJWTToken.test_generate_token
  test_users = TestUsers.new(token)

  # 获取用户列表
  test_users.test_list
  #test_users.test_modify

  # 移除用户
  #test_users.test_remove
end
