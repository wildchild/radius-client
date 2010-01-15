require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RADIUS::Client do
  before(:each) do
    @dict = RADIUS::Dictionary.new
    @dict << RADIUS::Attribute.new("User-Name", 1, :string)
    @dict << RADIUS::Attribute.new("User-Password", 2, :string)
  end

  describe "echo request" do
    before(:each) do
      @dict = RADIUS::Dictionary.new
      @dict << RADIUS::Attribute.new("User-Name", 1, :string)
      @dict << RADIUS::Attribute.new("User-Password", 2, :string)

      @client = RADIUS::Client.new(@dict, "0.0.0.0:9999", 3)
      @listener = UDPSocket::new
      @listener.bind("0.0.0.0", 9999)
    end

    it "should be successful" do
      pap = RADIUS::PAP.new("username", "password", "secret")
      request = RADIUS::AccessRequest.new(@dict, pap)
      request.identifier = 1

      receive_request
      response = @client.send(request)
      response.should be_instance_of(RADIUS::Packet)
      response.attributes.should == request.attributes
    end

    it "should be timed out" do
      @client.timeout = 0.01
      pap = RADIUS::PAP.new("username", "password", "secret")
      request = RADIUS::AccessRequest.new(@dict, pap)
      request.identifier = 1
      lambda { @client.send(request) }.should raise_exception(Timeout::Error)
    end

    def receive_request
      Thread.new do
        begin
          data, from = @listener.recvfrom(65536, 0)
          request = RADIUS::Packet.unpack(@dict, data)
          @listener.send(request.pack, 0, from[2], from[1])
          @listener.close
        rescue => e
          puts e.inspect
        end
      end
    end
  end
end
