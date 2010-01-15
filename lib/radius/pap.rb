require "digest/md5"

module RADIUS
  class PAP
    attr_accessor :login, :password, :secret

    def initialize(login, password, secret)
      self.login = login
      self.password = password
      self.secret = secret
    end

    def prepare(packet)
      packet["User-Name"] = login
      result = ""
      lastround = packet.authenticator
      self.password += "\000" * (15 - (15 + password.length) % 16)
      0.step(password.length - 1, 16) do |i|
        lastround = xor_string(password[i, 16], ::Digest::MD5.digest(secret + lastround))
        result += lastround
      end
      packet["User-Password"] = result
    end

    protected

    def xor_string(str1, str2)
      i = 0
      result = ""
      str1.each_byte do |c1|
        nresult = result << (c1 ^ str2[i])
        i = i + 1
      end
      result
    end
  end
end
