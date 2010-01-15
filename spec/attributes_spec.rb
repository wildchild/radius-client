require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RADIUS::Attribute do
  before(:each) do
    @dict = RADIUS::Dictionary.new
  end

  it "should encode/decode :string value" do
    @attribute = RADIUS::Attribute.new("User-Name", 1, :string)
    @dict << @attribute

    data = @attribute.pack("username")
    data.size.should == 10
    attribute, value = RADIUS::Attribute.unpack(@dict, 1, data[2..-1])
    attribute.should be_instance_of(RADIUS::Attribute)
    value.should == "username"
  end

  it "should encode/decode :ipaddr value" do
    @attribute = RADIUS::Attribute.new("Framed-IP-Address", 8, :ipaddr)
    @dict << @attribute

    data = @attribute.pack("127.0.0.1")
    data.size.should == 6
    attribute, value = RADIUS::Attribute.unpack(@dict, 8, data[2..-1])
    attribute.should be_instance_of(RADIUS::Attribute)
    value.should == "127.0.0.1"
  end

  it "should encode/decode :integer value" do
    @attribute = RADIUS::Attribute.new("Session-Timeout", 27, :integer)
    @dict << @attribute

    data = @attribute.pack(999)
    data.size.should == 6
    attribute, value = RADIUS::Attribute.unpack(@dict, 27, data[2..-1])
    attribute.should be_instance_of(RADIUS::Attribute)
    value.should == 999
  end

  it "should encode/decode :date value" do
    @attribute = RADIUS::Attribute.new("Event-Timestamp", 55, :date)
    @dict << @attribute
    now = Time.now

    data = @attribute.pack(now)
    data.size.should == 6
    attribute, value = RADIUS::Attribute.unpack(@dict, 55, data[2..-1])
    attribute.should be_instance_of(RADIUS::Attribute)
    value.should be_instance_of(Time)
    value.to_i.should == now.to_i
  end

  it "should encode/decode with value replacement" do
    values = { "Login-User" => 1, "Framed-User" => 2 }
    @attribute = RADIUS::Attribute.new("Service-Type", 6, :integer, values)
    @dict << @attribute

    data = @attribute.pack("Login-User")
    data.size.should == 6

    data = @attribute.pack(1)
    data.size.should == 6

    attribute, value = RADIUS::Attribute.unpack(@dict, 6, data[2..-1])
    value.should == "Login-User"
  end

  it "should raise an error when value is unknown" do
    values = { "Login-User" => 1, "Framed-User" => 2 }
    @attribute = RADIUS::Attribute.new("Service-Type", 6, :integer, values)
    @dict << @attribute
    lambda { @attribute.pack("Invalid-Value") }.should raise_exception(RADIUS::RadiusError)
  end

  it "should decode and keep original value when value is unknown" do
    values = { "Login-User" => 1, "Framed-User" => 2 }
    @attribute = RADIUS::Attribute.new("Service-Type", 6, :integer, values)
    @dict << @attribute

    data = @attribute.pack("Login-User")
    @attribute.values = {}
    attribute, value = RADIUS::Attribute.unpack(@dict, 6, data[2..-1])
    value.should == 1
  end
end

describe RADIUS::VendorSpecificAttribute do
  before(:each) do
    @dict = RADIUS::Dictionary.new
  end

  it "should encode/decode :string value" do
    @attribute = RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 1, :string)
    @dict << @attribute

    data = @attribute.pack("value")
    data.size.should == 13
    attribute, value = RADIUS::Attribute.unpack(@dict, 26, data[2..-1])
    attribute.should be_instance_of(RADIUS::VendorSpecificAttribute)
    attribute.type.should == 1
    attribute.vendor_id.should == 7
    attribute.should be_instance_of(RADIUS::VendorSpecificAttribute)
    value.should == "value"
  end

  it "should encode/decode :ipaddr value" do
    @attribute = RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 8, :ipaddr)
    @dict << @attribute

    data = @attribute.pack("127.0.0.1")
    data.size.should == 12
    attribute, value = RADIUS::Attribute.unpack(@dict, 26, data[2..-1])
    attribute.should be_instance_of(RADIUS::VendorSpecificAttribute)
    attribute.type.should == 8
    attribute.vendor_id.should == 7
    attribute.should be_instance_of(RADIUS::VendorSpecificAttribute)
    value.should == "127.0.0.1"
  end

  it "should encode/decode :integer value" do
    @attribute = RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 27, :integer)
    @dict << @attribute

    data = @attribute.pack(999)
    data.size.should == 12
    attribute, value = RADIUS::Attribute.unpack(@dict, 26, data[2..-1])
    attribute.should be_instance_of(RADIUS::VendorSpecificAttribute)
    attribute.type.should == 27
    attribute.vendor_id.should == 7
    value.should == 999
  end

  it "should encode/decode :date value" do
    @attribute = RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 55, :date)
    @dict << @attribute
    now = Time.now

    data = @attribute.pack(now)
    data.size.should == 12
    attribute, value = RADIUS::Attribute.unpack(@dict, 26, data[2..-1])
    attribute.should be_instance_of(RADIUS::VendorSpecificAttribute)
    attribute.type.should == 55
    attribute.vendor_id.should == 7
    value.should be_instance_of(Time)
    value.to_i.should == now.to_i
  end

  it "should encode/decode with value replacement" do
    values = { "First" => 1, "Second" => 2 }
    @attribute = RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 1, :integer, values)
    @dict << @attribute

    data = @attribute.pack("First")
    data.size.should == 12

    data = @attribute.pack(1)
    data.size.should == 12

    attribute, value = RADIUS::Attribute.unpack(@dict, 26, data[2..-1])
    value.should == "First"
  end

  it "should raise an error when value is unknown" do
    values = { "First" => 1, "Second" => 2 }
    @attribute = RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 1, :integer, values)
    @dict << @attribute
    lambda { @attribute.pack("Invalid-Value") }.should raise_exception(RADIUS::RadiusError)
  end

  it "should decode and keep original value when value is unknown" do
    values = { "First" => 1, "Second" => 2 }
    @attribute = RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 1, :integer, values)
    @dict << @attribute

    data = @attribute.pack("First")
    @attribute.values = {}
    attribute, value = RADIUS::Attribute.unpack(@dict, 26, data[2..-1])
    value.should == 1
  end
end
