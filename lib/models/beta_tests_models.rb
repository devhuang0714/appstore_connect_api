require 'json'

class BetaTesterCreateRequest
  # https://developer.apple.com/documentation/appstoreconnectapi/betatestercreaterequest
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
    #type: betaTesters
    attr_accessor :attributes, :relationships, :type

    def initialize(attributes:, relationships:, type:)
      @attributes = attributes
      @relationships = relationships
      @type = type
    end

    def self.from_hash(hash)
      attributes = Attributes.from_hash(hash['attributes'])
      relationships = hash['relationships'].nil? ? nil : Relationships.from_hash(hash['relationships'])
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
      attr_accessor :email, :firstName, :lastName

      def initialize(email:, firstName:, lastName:)
        @email = email
        @firstName = firstName
        @lastName = lastName
      end

      def self.from_hash(hash)
        new(
          email: hash['email'], 
          firstName: hash['firstName'], 
          lastName: hash['lastName'], 
        )
      end

      def to_hash
        {
          'email' =>  @email,
          'firstName' =>  @firstName,
          'lastName' =>  @lastName,
        }
      end
    end

    class Relationships
      attr_accessor :betaGroups, :builds

      def initialize(betaGroups: nil, builds: nil)
        @betaGroups = betaGroups
        @builds = builds
      end

      def self.from_hash(hash)
        new(
          betaGroups: BetaGroups.from_hash(hash['betaGroups']),
          builds: Builds.from_hash(hash['builds'])
        )
      end

      def to_hash
        {
          'betaGroups' =>  @betaGroups.nil? ? nil : @betaGroups.to_hash,
          'builds' =>  @builds.nil? ? nil : @builds.to_hash
        }
      end

      class BetaGroups        
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
          # type: betaGroups
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

      class Builds        
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
          # type: builds
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
