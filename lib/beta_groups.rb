require_relative '../utils/easy_http'
require_relative 'generate_jwt_token'

class BetaGroups
  # https://developer.apple.com/documentation/appstoreconnectapi/prerelease_versions_and_beta_testers/beta_groups
  
  def initialize(token)
    @token = token
    @headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@token}"
    }
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/list_beta_groups
  def list(query = nil)
    url = 'https://api.appstoreconnect.apple.com/v1/betaGroups'
    EasyHTTP.get(url, @headers, query)
  end

end

class TestBetaGroups
  
  def initialize(token)
    @beta_groups = BetaGroups.new(token)
  end

  def test_list
    @beta_groups.list
  end
end

if __FILE__ == $0
  token = GenerateJWTToken.test_generate_token
  test_beta_groups = TestBetaGroups.new(token)
  test_beta_groups.test_list
end
