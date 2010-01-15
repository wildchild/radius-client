module RADIUS
  class Client
    attr_accessor :dictionary, :host, :port, :timeout
    attr_reader :request, :response

    def initialize(dictionary, endpoint, timeout = 3)
      self.dictionary = dictionary
      self.host, self.port = endpoint.split(":")
      self.port = port || Socket.getservbyname("radius", "udp")
      self.port ||= 1812
      self.port = port.to_i
      self.timeout = timeout
      @sock = UDPSocket.new
      @sock.connect(host, port)
    end

    def send(request)
      @request = request
      send_request
      recv_response
    end

    def close
      @sock.close if @sock
    end

    protected

    def send_request
      @sock.send(@request.pack, 0)
    end

    def recv_response
      Timeout::timeout(self.timeout) do
        @response, from = @sock.recvfrom(65536)
        Packet.unpack(dictionary, @response)
      end
    end
  end
end
