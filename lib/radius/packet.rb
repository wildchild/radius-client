module RADIUS
  class RadiusError < StandardError; end

  class Packet

    class << self
      def unpack(dictionary, data)
        code, identifier, len, authenticator, attrdat = data.unpack("CCna16a*")
        attributes = {}

        while (attrdat.length > 0)
          length = attrdat.unpack("xC")[0].to_i
          type, value = attrdat.unpack("Cxa#{length - 2}")
          attribute, value = Attribute.unpack(dictionary, type.to_i, value)
          attributes[attribute.name] = value
          attrdat[0, length] = ""
        end

        packet = Packet.new(dictionary, code, attributes)
        packet.identifier = identifier
        packet.authenticator = authenticator
        packet
      end
    end

    attr_accessor :code, :identifier, :authenticator, :dictionary, :attributes

    def initialize(dictionary, code, attributes = {})
      self.code = code
      self.dictionary = dictionary
      self.attributes = attributes
    end

    def [](name)
      attributes[name]
    end

    def []=(name, value)
      attributes[name] = value
    end

    def pack
      attrstr = ""
      attributes.each do |name, value|
        attribute = dictionary[name]
        raise RadiusError, "Unknown attribute #{name}" unless attribute
        attrstr << attribute.pack(value)
      end
      [code, identifier, attrstr.length + 20, authenticator, attrstr].pack("CCna16a*")
    end

    def each
      attributes.each_pair do |name, value|
	      yield(name, value)
      end
    end
  end

  class AccessRequest < Packet
    attr_accessor :auth_type

    def initialize(dictionary, auth_type, attributes = {})
      self.auth_type = auth_type
      super(dictionary, 1, attributes)
    end

    def identifier=(value)
      value = value & 0xff

      if identifier != value
        @identifier = value
        gen_authenticator
      end
    end

    def pack
      auth_type.prepare(self)
      gen_authenticator unless authenticator
      super
    end

    protected

    def gen_authenticator
      value = []
      8.times { value << rand(65536) }
      self.authenticator = value.pack("n8")
    end
  end
end
