require 'json'

class CertifiateCreateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/certificatecreaterequest

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
    # type: certificates
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
      # https://developer.apple.com/documentation/appstoreconnectapi/certificatetype
      # certificateType: DEVELOPMENT, DISTRIBUTION, ...
      attr_accessor :certificateType, :csrContent

      def initialize(certificateType:, csrContent:)
        @certificateType = certificateType
        @csrContent = csrContent
      end

      def self.from_hash(hash)
        new(
          certificateType: hash['certificateType'], 
          csrContent: hash['csrContent']
        )
      end

      def to_hash
        {
          'certificateType' => @certificateType,
          'csrContent' => @csrContent
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
         "certificateType": "DEVELOPMENT",
         "csrContent": "this is csrcontent"
      },
      "type": "certificates"
    }
  }
  JSON
  hash = JSON.parse(json_string)

  request = CertifiateCreateRequest.from_hash(hash)
  puts request.data.type
  puts request.to_hash
end
