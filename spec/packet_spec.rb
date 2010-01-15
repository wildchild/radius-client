require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RADIUS::Packet do
  before(:each) do
    @dict = RADIUS::Dictionary.new
    @dict << RADIUS::Attribute.new("User-Name", 1, :string)
    @dict << RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 88, :string)
  end

  it "should encode/decode properly" do
    packet = RADIUS::Packet.new(@dict, 1)
    packet["User-Name"] = "username"
    packet["Vendor-Specific"] = "value"
    packet.identifier = 1
    packet.authenticator = [1, 2, 3, 4, 5, 6, 7, 8].pack("n8")

    result = RADIUS::Packet.unpack(@dict, packet.pack)
    result.identifier.should == packet.identifier
    result.authenticator.should == packet.authenticator
    result.attributes.should == packet.attributes
  end

  describe "encoding" do
    it "should raise an error on unknown attribute" do
      packet = RADIUS::Packet.new(RADIUS::Dictionary.new, 1)
      packet["Unknown-Attribute"] = "value"
      packet.identifier = 1
      packet.authenticator = [1, 2, 3, 4, 5, 6, 7, 8].pack("n8")
      lambda { packet.pack }.should raise_exception(RADIUS::RadiusError)
    end
  end

  describe "decoding" do
    it "should raise an error on unknown attribute" do
      empty_dict = RADIUS::Dictionary.new
      packet = RADIUS::Packet.new(@dict, 1)
      packet["User-Name"] = "username"
      packet.identifier = 1
      packet.authenticator = [1, 2, 3, 4, 5, 6, 7, 8].pack("n8")
      data = packet.pack
      lambda { RADIUS::Packet.unpack(empty_dict, data) }.should raise_exception(RADIUS::RadiusError)
    end
  end
end

describe RADIUS::AccessRequest do
  before(:each) do
    @dict = RADIUS::Dictionary.new
    @dict << RADIUS::Attribute.new("User-Name", 1, :string)
    @dict << RADIUS::Attribute.new("User-Password", 2, :string)
  end

  describe "with PAP authentication type" do
    it "should populate packet with PAP attributes" do
      pap = RADIUS::PAP.new("username", "password", "secret")
      packet = RADIUS::AccessRequest.new(@dict, pap)
      packet.identifier = 1
      packet.pack

      packet.code.should == 1
      packet["User-Name"].should == "username"
      packet["User-Password"].should_not == "password"
    end

    it "should encode/decode properly" do
      pap = RADIUS::PAP.new("username", "password", "secret")
      packet = RADIUS::AccessRequest.new(@dict, pap)
      packet.identifier = 1
      data = packet.pack
      lambda { RADIUS::AccessRequest.unpack(@dict, data) }.should_not raise_error
    end
  end
end
