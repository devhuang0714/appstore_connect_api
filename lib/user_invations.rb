require 'json'
require_relative '../utils/easy_http'
require_relative 'generate_jwt_token'
require_relative 'models/users_models'

class UserInvitations
  # https://developer.apple.com/documentation/appstoreconnectapi/user_invitations

  def initialize(token)
    @token = token
    @headers = {
      'Authorization' => "Bearer #{@token}",
      'Content-Type' => 'application/json'
    }
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/list_invited_users
  def list(query = nil)
    url = 'https://api.appstoreconnect.apple.com/v1/userInvitations'
    EasyHTTP.get(url, @headers, query)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/read_user_invitation_information
  def info(id, query = nil)
    url = "https://api.appstoreconnect.apple.com/v1/userInvitations/#{id}"
    EasyHTTP.get(url, @headers, query)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/invite_a_user
  def invite(user_invitation_create_request)
    url = 'https://api.appstoreconnect.apple.com/v1/userInvitations'
    body = user_invitation_create_request.to_hash.deep_compact
    EasyHTTP.post(url, @headers, body)
  end

  # https://developer.apple.com/documentation/appstoreconnectapi/cancel_a_user_invitation
  # response code: 204 success
  def cancel(id)
    url = "https://api.appstoreconnect.apple.com/v1/userInvitations/#{id}"
    EasyHTTP.delete(url, @headers)
  end
end

class TestUserInvitations

  def initialize(token)
    @user_invitations = UserInvitations.new(token)
  end

  def test_invite
    attributes = UserInvitationCreateRequest::Data::Attributes.new(
      email: 'hytest2020@yeah.net',
      firstName: '名',
      lastName: '莫',
      roles: [UserRole::DEVELOPER],
      allAppsVisible: true,
      provisioningAllowed: true
    )
    relationships = UserInvitationCreateRequest::Data::Relationships.new(
      visibleApps: nil
    )
    data = UserInvitationCreateRequest::Data.new(
      attributes: attributes,
      relationships: nil,
      type: 'userInvitations'
    )
    request = UserInvitationCreateRequest.new(data: data)
    res = @user_invitations.invite(request)
    if res.code == '201'
      puts "用户邀请已发送"
    end
  end

end

if __FILE__ == $0
  token = GenerateJWTToken.test_generate_token
  test_user_invitations = TestUserInvitations.new(token)
  #test_user_invitations.test_invite

  test_user_invitations.list
end
