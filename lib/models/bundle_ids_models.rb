require 'json'

class BundleIdCreateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/bundleidcreaterequest

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

  class Data
    #type: bundleIds
    attr_accessor :attributes, :type

    def initialize(attributes:, type:)
      @attributes = attributes
      @type = type
    end

    def self.from_hash(hash)
      new(
        attributes: Attributes.from_hash(hash['attributes']), 
        type: hash['type']
      )
    end

    def to_hash
      {
        'attributes' => @attributes.to_hash,
        'type' => @type
      }
    end

    class Attributes
      # platfrom: IOS, MAC_OS
      # seedId: [Optional] Team ID
      attr_accessor :identifier, :name, :platform, :seedId
     
      def initialize(identifier:, name:, platform:, seedId: nil)
        @identifier = identifier
        @name = name
        @platform = platform
        @seedId = seedId
      end

      def self.from_hash(hash)
        new(
          identifier: hash['identifier'], 
          name: hash['name'], 
          platform: hash['platform'], 
          seedId: hash['seedId']
        )
      end

      def to_hash
        {
          'identifier' => @identifier,
          'name' => @name,
          'platform' => @platform,
          'seedId' => @seedId
        }
      end
    end
  end
end

class BundleIdUpdateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/bundleidupdaterequest
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
  
  class Data
    #type: bundleIds
    attr_accessor :attributes, :id, :type

    def initialize(attributes:, id:, type:)
      @attributes = attributes
      @id = id
      @type = type
    end

    def self.from_hash(hash)
      new(
        attributes: Attributes.from_hash(hash['attributes']), 
        id: hash['id'],
        type: hash['type']
      )
    end

    def to_hash
      {
        'attributes' => @attributes.to_hash,
        'id' => @id,
        'type' => @type
      }
    end

    class Attributes
      # platfrom: IOS, MAC_OS
      # seedId: [Optional] Team ID
      attr_accessor :name
     
      def initialize(name:)
        @name = name
      end

      def self.from_hash(hash)
        new(
          name: hash['name']
        )
      end

      def to_hash
        {
          'name' => @name
        }
      end
    end
  end
end

if __FILE__ == $0
  hash_string = <<~JSON
  {
      "data": {
          "attributes": {
              "name": "test1",
              "identifier": "com.shangyewd.test1",
              "seedId": "3KBC6MT95W",
              "platform": "IOS"
          },
          "type": "bundleIds"
      }
  }
  JSON
  hash = JSON.parse(hash_string)

  puts hash
  request = BundleIdCreateRequest.from_hash(hash)
  puts request.data.type
  puts request.to_hash
  puts JSON.dump(request.to_hash)
end
