module RADIUS
  class Attribute
    attr_accessor :name, :type, :data_type, :values

    class << self
      def unpack(dictionary, type, data)
        if type == 26
          VendorSpecificAttribute.unpack(dictionary, data)
        else
          attribute = dictionary.by_type(type)
          raise RadiusError, "Unknown attribute #{type}" unless attribute
          val = attribute.unpack_value(data)
          [attribute, val]
        end
      end
    end

    def initialize(name, type, data_type, values = {})
      self.name = name
      self.type = type
      self.data_type = data_type
      self.values = values
    end

    def pack(value)
      val = pack_value(value)
      [type, val.length + 2, val].pack("CCa*")
    end

    def pack_value(value)
      case data_type
      when :string
        value.to_s
      when :integer
        if values.has_key?(value)
          [values[value]].pack("N")
        elsif value.is_a?(Numeric)
          [value].pack("N")
        else
          raise RadiusError, "Unknown attribute value #{value}"
        end
      when :ipaddr
        value = value.split(/\./).map{ |c| c.to_i }.pack("C*").unpack("N")[0]
        [value].pack("N")
      when :date
        [value.to_i].pack("N")
      else
        value
      end
    end

    def unpack_value(data)
      case data_type
      when :string
        data
      when :integer
        value = data.unpack("N")[0]
        values.invert[value] || value
      when :ipaddr
        n = data.unpack("N")[0]
        [n].pack("N").unpack("C*").join(".")
      when :date
        Time.at(data.unpack("N")[0])
      else
        data
      end
		end
  end

  class VendorSpecificAttribute < Attribute
    attr_accessor :vendor_id

    class << self
      def unpack(dictionary, data)
        vendor_id, type, length = data.unpack("NCC")
        value = data.unpack("xxxxxxa#{length - 2}")[0]
        attribute = dictionary.by_vs_type(vendor_id, type)
        raise RadiusError, "Unknown vendor-specific attribute #{vendor_id}/#{type}" unless attribute
        [attribute, attribute.unpack_value(value)]
      end
    end

    def initialize(name, vendor_id, type, data_type, values = {})
      self.vendor_id = vendor_id
      super(name, type, data_type, values)
    end

    def pack(value)
      val = pack_value(value)
      [26, val.length + 8, vendor_id, type, val.length + 2, val].pack("CCNCCa*")
    end
  end

  class Dictionary

    def initialize
      @by_names = {}
      @by_codes = {}
    end

    def <<(value)
      @by_names[value.name] = value

      if value.respond_to?(:vendor_id)
        key = [value.vendor_id, value.type]
        @by_codes[key] = value
      else
        @by_codes[value.type] = value
      end
    end

    def [](name)
      @by_names[name]
    end

    def by_type(type)
      @by_codes[type]
    end

    def by_vs_type(vendor_id, type)
      @by_codes[[vendor_id, type]]
    end
  end
end
