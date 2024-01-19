require 'json'

class DeviceCreateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/devicecreaterequest

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
    # type: devices
    attr_accessor :attributes, :type

    def initialize(attributes:, type: 'devices')
      @attributes = attributes
      @type = type
    end

    def self.from_hash(hash)
      puts "data #{hash}"
      new(
        attributes: Attributes.from_hash(hash['attributes']), 
        type: hash['type']
      )
    end

    def to_hash
      {
        'attributes' => @attributes.nil? ? nil : @attributes.to_hash,
        'type' => @type
      }
    end

    class Attributes
      attr_accessor :name, :platform, :udid

      def initialize(name:, platform:, udid:)
        @name = name
        @platform = platform
        @udid = udid
      end

      def self.from_hash(hash)
        new(
          name: hash['name'], 
          platform: hash['platform'], 
          udid: hash['udid']
        )
      end

      def to_hash
        {
          'name' => @name,
          'platform' => @platform,
          'udid' => @udid
        } 
      end
    end
  end
end

class DevicesUpdateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/deviceupdaterequest

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
    # type: devices
    attr_accessor :attributes, :id, :type

    def initialize(attributes:, id:, type: 'devices')
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
        'attributes' => @attributes.nil? ? nil : @attributes.to_hash,
        'id' => @id,
        'type' => @type
      }
    end

    class Attributes
      # status: ENABLED, DISABLED
      attr_accessor :name, :status

      def initialize(name:, status:)
        @name = name
        @status = name
      end

      def self.from_hash(hash)
        new(
          name: hash['name'],
          status: hash['status']
        )
      end

      def to_hash
        {
          'name' => @name,
          'status' => @status
        }
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
              "udid": "f51f5b7c677565cfa629xxxxxxxxx",
              "platform": "IOS"
          },
          "type": "devices"
      }
  }
  JSON

  hash = JSON.parse(json_string)
  request = DeviceCreateRequest.from_hash(hash)
  puts request.inspect
  puts request.data.type
  puts request.to_hash
end
