require_relative 'generate_jwt_token'
require_relative '../utils/easy_http'
require_relative 'beta_groups'
require_relative 'models/beta_tests_models'

class BetaTesters
  # https://developer.apple.com/documentation/appstoreconnectapi/prerelease_versions_and_beta_testers/beta_testers

  def initialize(token)
    @token = token
    @headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@token}"
    }
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/create_a_beta_tester
  def create(beta_tests_create_request)
    url = 'https://api.appstoreconnect.apple.com/v1/betaTesters'
    body = beta_tests_create_request.to_hash.deep_compact
    EasyHTTP.post(url, @headers, body)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/delete_a_beta_tester
  # response code: 204 success
  def delete(id)
    url = "https://api.appstoreconnect.apple.com/v1/betaTesters/#{id}"
    EasyHTTP.delete(url, @headers)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/list_beta_testers
  def list(query = nil)
    url = 'https://api.appstoreconnect.apple.com/v1/betaTesters'
    EasyHTTP.get(url, @headers, query)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/read_beta_tester_information
  def info(id, query = nil)
    url = "https://api.appstoreconnect.apple.com/v1/betaTesters/#{id}"
    EasyHTTP.get(url, @headers, query)
  end
end

class TestBetaTesters
  
  def initialize(token)
    @token = token
    @beta_tests = BetaTesters.new(token)
  end

  def test_create
    beta_groups_api = BetaGroups.new(@token)
    res = beta_groups_api.list
    relationships = nil
    if res.code == '200'
      data = JSON.parse(res.body)['data'].first
      betaGroups_data = BetaTesterCreateRequest::Data::Relationships::BetaGroups::Data.from_hash(data)
      betaGroups = BetaTesterCreateRequest::Data::Relationships::BetaGroups.new(data: [betaGroups_data]) 
      relationships = BetaTesterCreateRequest::Data::Relationships.new(betaGroups: betaGroups)
    end
    
    attributes = BetaTesterCreateRequest::Data::Attributes.new(
      email: 'hytest2020@yeah.net',
      firstName: '名',
      lastName: '莫'
    )
    request_data = BetaTesterCreateRequest::Data.new(
      attributes: attributes,
      relationships: relationships,
      type: 'betaTesters'
    )
    request = BetaTesterCreateRequest.new(data: request_data)
    @beta_tests.create(request)
  end

  def test_list
    @beta_tests.list
  end
end

if __FILE__ == $0
  token = GenerateJWTToken.test_generate_token
  test_beta_tests = TestBetaTesters.new(token)

  test_beta_tests.test_create

  #test_beta_tests.test_list
end
