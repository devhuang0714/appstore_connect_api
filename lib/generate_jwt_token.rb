require 'jwt'
require_relative '../utils/easy_http'

class GenerateJWTToken
  # https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests

  def initialize(issuer_id:, key_id:, private_key:)
    @issuer_id = issuer_id
    @key_id = key_id
    @private_key = private_key
  end

  def token
    header = {
      'alg': 'ES256',
      'kid': @key_id,
      'typ': 'JWT'
    }

    payload = {
      'iss': @issuer_id,
    #  'iat': Time.now.to_i,
      'exp': Time.now.to_i + 1200, 
      'aud': 'appstoreconnect-v1'
    #  'scope': [
    #    'GET /v1/apps?filter[platform]=IOS'
    #  ]
    }

    key = OpenSSL::PKey.read(@private_key)
    token = JWT.encode(
       payload,
       key,
       'ES256',
       header
    )

    return token
  end

  def self.test_generate_token
    if File.exist?('tmp/token.txt')
      token = File.read('tmp/token.txt')
      # 校验token是否有效
      res = EasyHTTP.get('https://api.appstoreconnect.apple.com/v1/apps', { 'Authorization': "Bearer #{token}"})
      if res.code == '200'
        puts "Use local token: #{token}"
        return token
      end
    end

    issuer_id = 'your issuer id'
    key_id = 'your key id'                            

    private_key= "-----BEGIN PRIVATE KEY-----<your private key>-----END PRIVATE KEY-----"
    generate = GenerateJWTToken.new(issuer_id: issuer_id, key_id: key_id, private_key: private_key)
    token = generate.token
    puts "JWT Token: #{token}"
    File.open('token.txt', 'w') do |file|
      file.write token
    end
    return token
  end
end

if __FILE__ == $0
  GenerateJWTToken.test_generate_token
end
