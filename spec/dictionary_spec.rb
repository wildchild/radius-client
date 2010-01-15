require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RADIUS::Dictionary do
  before(:each) do
    @dict = RADIUS::Dictionary.new
    @dict << RADIUS::Attribute.new("User-Name", 1, :string)
    @dict << RADIUS::VendorSpecificAttribute.new("Vendor-Specific", 7, 5, :string)
  end

  it "should allow to store attributes" do
    @dict << RADIUS::Attribute.new("Framed-Pool", 88, :string)
    @dict["Framed-Pool"].should_not be_nil
  end

  it "should allow to search for attributes by name" do
    attribute = @dict["User-Name"]
    attribute.should_not be_nil
    attribute.name.should == "User-Name"
    attribute.type.should == 1
  end

  it "should allow to search for attributes by code" do
    attribute = @dict.by_type(1)
    attribute.should_not be_nil
    attribute.name.should == "User-Name"
    attribute.type.should == 1
  end

  it "should allow to search for attributes by code and vendor" do
    attribute = @dict.by_vs_type(7, 5)
    attribute.should_not be_nil
    attribute.name.should == "Vendor-Specific"
    attribute.type.should == 5
    attribute.vendor_id.should == 7
  end
end
