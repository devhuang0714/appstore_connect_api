require 'json'

class ProfileCreateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/profilecreaterequest
  
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
      'data' => @data.nil? ? nil : @data.to_hash
    }
  end

  class Data
    # type: profiles
    attr_accessor :attributes, :relationships, :type

    def initialize(attributes:, relationships:, type:)
      @attributes = attributes
      @relationships = relationships
      @type = type
    end

    def self.from_hash(hash)
      new(
        attributes: Attributes.from_hash(hash['attributes']),
        relationships: Relationships.from_hash(hash['relationships']),
        type: hash['type']
      )
    end

    def to_hash
      {
        'attributes' => @attributes.nil? ? nil : @attributes.to_hash,
        'relationships' => @relationships.nil? ? nil : @relationships.to_hash,
        'type' => @type
      }
    end

    class Attributes
      # profileType: IOS_APP_DEVELOPMENT, IOS_APP_STORE, IOS_APP_ADHOC
      attr_accessor :name, :profileType

      def initialize(name:, profileType:)
        @name = name
        @profileType = profileType
      end

      def self.from_hash(hash)
        new(
          name: hash['name'], 
          profileType: hash['profileType']
        )
      end

      def to_hash
        {
          'name' => @name,
          'profileType' => @profileType
        }
      end
    end

    class Relationships
      attr_accessor :bundleId, :certificates, :devices

      def initialize(bundleId:, certificates:, devices:)
        @bundleId = bundleId
        @certificates = certificates
        @devices = devices
      end

      def self.from_hash(hash)
        new(
          bundleId: BundleId.from_hash(hash['bundleId']),
          certificates: Certificates.from_hash(hash['certificates']),
          devices: Devices.from_hash(hash['devices'])
        )
      end

      def to_hash
        {
          'bundleId' => @bundleId.nil? ? nil : @bundleId.to_hash,
          'certificates' => @certificates.nil? ? nil : @certificates.to_hash,
          'devices': @devices.nil? ? nil : @devices.to_hash
        }
      end

      class Data
        # type: bundleIds, certificates, devices
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
            'id' => @id,
            'type' => @type
          }
        end
      end

      class BundleId
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
            'data' => @data.to_hash
          }
        end
      end

      class Certificates
        # [Data]
        attr_accessor :data

        def initialize(data:)
          @data = data
        end
        
        def self.from_hash(hash)
          new(
            data: hash['data'].map { |item| Data.from_hash(item) }
          )
        end

        def to_hash
          {
            'data' => @data.nil? ? nil : @data.map { |item| item.to_hash }
          }
        end
      end

      class Devices
        # [Data]
        attr_accessor :data

        def initialize(data:)
          @data = data
        end
        
        def self.from_hash(hash)
          new(
            data: hash['data'].map { |item| Data.from_hash(item) }
          )
        end

        def to_hash
          {
            'data' => @data.nil? ? nil : @data.map { |item| item.to_hash }
          }
        end
      end
    end
  end
end

if __FILE__ == $0
  json_string = <<~JSON
  {
      "data": {
          "attributes": {
              "name": "test_se",
              "profileType": "IOS_APP_DEVELOPMENT"
          },
          "type": "profiles",
          "relationships": {
              "bundleId": {
                  "data": {
                      "id": "TH9XXXX",
                      "type": "bundleIds"
                  }
              },
              "certificates": {
                  "data": [
                      {
                          "id": "5DWXXXXX",
                          "type": "certificates"
                      }
                  ]
              },
              "devices": {
                  "data": [
                      {
                          "id": "7BUHXXXXX",
                          "type": "devices"
                      }
                  ]
              }
          }
      }
  }
  JSON
  hash = JSON.parse(json_string)  
  request = ProfileCreateRequest.from_hash(hash)
  puts request.inspect
  puts request.data.type
  puts request.to_hash
  puts JSON.dump(request.to_hash)
end
