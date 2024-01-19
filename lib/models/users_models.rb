require 'json'

module UserRole
  # https://developer.apple.com/documentation/appstoreconnectapi/userrole
  
  #Permission to download reports associated with a role. The Access To Reports permission is an additional permission for users with the App Manager, Developer, Marketing, or Sales role. If you add this permission, the user has access to all of your apps.
  #  下载与角色关联的报告的权限。“访问报告”权限是具有应用程序管理员、开发人员、市场营销或销售角色的用户的附加权限。如果您添加此权限，用户将有权访问您的所有应用。
  ACCESS_TO_REPORTS = 'ACCESS_TO_REPORTS'

  #Role responsible for entering into legal agreements with Apple. The person who completes program enrollment has the Account Holder role in their Apple Developer account and their App Store Connect account.
  #  负责与Apple签订法律的协议。完成计划注册的人员在其Apple Developer帐户和App Store Connect帐户中拥有帐户保持器角色。
  ACCOUNT_HOLDER = 'ACCOUNT_HOLDER'

  #Role that serves as a secondary contact for teams and has many of the same responsibilities as the Account Holder role. Admins have access to all apps.
  #  作为团队的第二联系人的角色，其职责与客户保持器角色相同。管理员可以访问所有应用程序。
  ADMIN = 'ADMIN'

  #Role that manages all aspects of an app, such as pricing, App Store information, and app development and delivery.
  #  管理应用程序所有方面的角色，例如定价、应用程序商店信息以及应用程序开发和交付。
  APP_MANAGER = 'APP_MANAGER'

  #Permission to submit requests for apps and software to be signed by a cloud-managed Apple Distribution certificate. App Store Connect automatically creates a certificate if one doesn’t exist. The system grants this permission by default to Account Holder and Admin roles. Account Holder, Admin, and App Manager roles may grant access to this permission to other users with App Manager or Developer roles. This permission requires that the user has access to Certificates, Identifiers & Profiles.
  #  允许提交应用和软件的请求，以便由云管理的Apple Distribution证书进行签名。如果证书不存在，App Store Connect会自动创建证书。默认情况下，系统将此权限授予帐户保持器和管理员角色。帐户保持器、管理员和应用程序管理员角色可以将此权限授予具有应用程序管理员或开发人员角色的其他用户。此权限要求用户有权访问证书、标识符和配置文件。
  CLOUD_MANAGED_APP_DISTRIBUTION = 'CLOUD_MANAGED_APP_DISTRIBUTION'

  #Permission to submit requests for apps and software to be cloud signed by a cloud-managed Developer ID certificate. App Store Connect automatically creates a certificate if one doesn’t exist. The system grants this permission by default to the Account Holder role. The Account Holder may grant access to this permission to users with the Admin role, who may grant it to other Admins. This permission requires that the user has access to Certificates, Identifiers & Profiles.
  #  允许提交应用和软件的请求，以通过云管理的开发人员ID证书进行云签名。如果证书不存在，App Store Connect会自动创建证书。默认情况下，系统将此权限授予帐户保持器角色。帐户保持器可将此权限授予具有管理员角色的用户，而管理员角色可将此权限授予其他管理员。此权限要求用户有权访问证书、标识符和配置文件。
  CLOUD_MANAGED_DEVELOPER_ID = 'CLOUD_MANAGED_DEVELOPER_ID'

  #A permission that enables users with Developer or Marketing roles to create app records.
  #  允许具有开发人员或市场营销角色的用户创建应用记录的权限。
  CREATE_APPS = 'CREATE_APPS'

  #Role that analyzes and responds to customer reviews on the App Store. If a user has only the Customer Support role, they go straight to the Ratings and Reviews section when they click on an app in My Apps.
  #  分析和响应App Store上的客户评论的角色。如果用户只有“客户支持”角色，则在单击“我的应用”中的应用时，他们会直接转到“评级和评论”部分。
  CUSTOMER_SUPPORT = 'CUSTOMER_SUPPORT'

  #Role that manages development and delivery of an app.'
  #  管理应用程序的开发和交付的角色。
  DEVELOPER = 'DEVELOPER'

  #Role that manages financial information, including reports and tax forms. A user that has this role can view all apps in Payments and Financial Reports, Sales and Trends, and App Analytics.
  #  管理财务信息的角色，包括报表和纳税申报表。拥有此角色的用户可以查看支付和财务报告、销售和趋势以及应用分析中的所有应用。
  FINANCE = 'FINANCE'

  IMAGE_MANAGER = 'IMAGE_MANAGER'
  #Role that manages marketing materials and promotional artwork. If an app is in consideration to be featured on the App Store, Apple contacts the user with this role.
  #  管理市场营销材料和促销艺术品。如果一个应用程序被考虑在App Store上展示，Apple会联系具有此角色的用户。
  MARKETING = 'MARKETING'

  #Role that analyzes sales, downloads, and other analytics for the app.
  #  分析应用程序的销售、下载和其他分析的角色。
  SALES = 'SALES'
end

class UserUpdateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/userupdaterequest
  attr_accessor :data

  def initialize(data:)
    @data = data
  end

  def self.from_hash(hash)
    new(
      data: Data.from_hash(hash['data'])
    )
  end

  def to_hash
    {
      'data' =>  @data.to_hash
    }
  end

  class Data
    #type: users
    attr_accessor :id, :attributes, :relationships, :type

    def initialize(id:, attributes:, relationships:, type:)
      @id = id
      @attributes = attributes
      @relationships = relationships
      @type = type
    end

    def self.from_hash(hash)
      attributes = Attributes.from_hash(hash['attributes'])
      relationships = Relationships.from_hash(hash['relationships'])
      new(
        id: hash['id'],
        attributes: attributes, 
        relationships: relationships, 
        type: hash['type']
      )
    end

    def to_hash
      {
        'id' => @id,
        'attributes' => @attributes.nil? ? nil :  @attributes.to_hash,
        'relationships' => @relationships.nil? ? nil : @relationships.to_hash,
        'type' =>  @type
      }
    end

    class Attributes
      attr_accessor :allAppsVisible, :provisioningAllowed, :roles

      def initialize(allAppsVisible:, provisioningAllowed:, roles:)
        @allAppsVisible = allAppsVisible
        @provisioningAllowed = provisioningAllowed
        @roles = roles
      end

      def self.from_hash(hash)
        new(
          allAppsVisible: hash['allAppsVisible'], 
          provisioningAllowed: hash['provisioningAllowed'], 
          roles: hash['roles']
        )
      end

      def to_hash
        {
          'allAppsVisible' =>  @allAppsVisible,
          'provisioningAllowed' =>  @provisioningAllowed,
          'roles' =>  @roles
        }
      end
    end

    class Relationships
      attr_accessor :visibleApps

      def initialize(visibleApps:)
        @visibleApps = visibleApps
      end

      def self.from_hash(hash)
        new(
          visibleApps: VisibleApps.from_hash(hash['visibleApps'])
        )
      end

      def to_hash
        {
          'visibleApps' =>  @visibleApps.nil? ? nil : @visibleApps.to_hash
        }
      end

      class VisibleApps        
        # [Data]
        attr_accessor :data

        def initialize(data:)
          @data = data
        end

        def self.from_hash(hash)
          unless hash['data'].nil?
            new(
              data: hash['data'].map { |item| Data.from_hash(item) }
            )
          end
        end

        def to_hash
          {
            'data' =>  @data.nil? ? nil : @data.map { |item| item.to_hash }
          }
        end

        class Data
          # type: apps
          attr_accessor :id, :type

          def initialize(id:, type:)
            @id = id
            @type = type
          end

          def self.from_hash(hash)
            new(
              id: hash['id'], 
              type: hash['type']
            )
          end

          def to_hash
            {
              'id' =>  @id,
              'type' =>  @type
            }
          end
        end
      end
    end
  end
end

class UserInvitationCreateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/userinvitationcreaterequest
  attr_accessor :data

  def initialize(data:)
    @data = data
  end

  def self.from_hash(hash)
    new(
      data: Data.from_hash(hash['data'])
    )
  end

  def to_hash
    {
      'data' =>  @data.to_hash
    }
  end

  class Data
    #type: users
    attr_accessor :attributes, :relationships, :type

    def initialize(attributes:, relationships:, type:)
      @attributes = attributes
      @relationships = relationships
      @type = type
    end

    def self.from_hash(hash)
      attributes = Attributes.from_hash(hash['attributes'])
      relationships = Relationships.from_hash(hash['relationships'])
      new(
        attributes: attributes, 
        relationships: relationships, 
        type: hash['type']
      )
    end

    def to_hash
      {
        'attributes' => @attributes.nil? ? nil :  @attributes.to_hash,
        'relationships' => @relationships.nil? ? nil : @relationships.to_hash,
        'type' =>  @type
      }
    end

    class Attributes
      attr_accessor :allAppsVisible, :email, :firstName, :lastName, :provisioningAllowed, :roles

      def initialize(allAppsVisible:, email:, firstName:, lastName:, provisioningAllowed:, roles:)
        @allAppsVisible = allAppsVisible
        @email = email
        @firstName = firstName
        @lastName = lastName
        @provisioningAllowed = provisioningAllowed
        @roles = roles
      end

      def self.from_hash(hash)
        new(
          allAppsVisible: hash['allAppsVisible'], 
          email: hash['email'], 
          firstName: hash['firstName'], 
          lastName: hash['lastName'], 
          provisioningAllowed: hash['provisioningAllowed'], 
          roles: hash['roles']
        )
      end

      def to_hash
        {
          'allAppsVisible' =>  @allAppsVisible,
          'email' =>  @email,
          'firstName' =>  @firstName,
          'lastName' =>  @lastName,
          'provisioningAllowed' =>  @provisioningAllowed,
          'roles' =>  @roles
        }
      end
    end

    class Relationships
      attr_accessor :visibleApps

      def initialize(visibleApps:)
        @visibleApps = visibleApps
      end

      def self.from_hash(hash)
        new(
          visibleApps: VisibleApps.from_hash(hash['visibleApps'])
        )
      end

      def to_hash
        {
          'visibleApps' =>  @visibleApps.nil? ? nil : @visibleApps.to_hash
        }
      end

      class VisibleApps        
        # [Data]
        attr_accessor :data

        def initialize(data:)
          @data = data
        end

        def self.from_hash(hash)
          unless hash['data'].nil?
            new(
              data: hash['data'].map { |item| Data.from_hash(item) }
            )
          end
        end

        def to_hash
          {
            'data' =>  @data.nil? ? nil : @data.map { |item| item.to_hash }
          }
        end

        class Data
          attr_accessor :id, :type

          def initialize(id:, type:)
            @id = id
            @type = type
          end

          def self.from_hash(hash)
            new(
              id: hash['id'], 
              type: hash['type']
            )
          end

          def to_hash
            {
              'id' =>  @id,
              'type' =>  @type
            }
          end
        end
      end
    end
  end
end

if __FILE__ == $0

  json_string = <<~JSON
    {
      "data": {
          "type" : "userInvitations",
          "attributes" : {
            "email" : "test_user@163.com",
            "firstName" : "名",
            "lastName" : "姓",
            "roles" : [ "ADMIN"],
            "allAppsVisible" : true,
            "provisioningAllowed" : true
          },
          "relationships" : {
            "visibleApps" : {
            }
          }
      }
    } 
  JSON

  hash = JSON.parse(json_string)
  request = UserInvitationCreateRequest.from_hash(hash)
  puts request.inspect
  puts JSON.dump(request.to_hash)

  hash['data']['id'] = '123456'
  hash['data']['type'] = 'users'
  update_request = UserUpdateRequest.from_hash(hash)
  puts update_request.inspect

end
