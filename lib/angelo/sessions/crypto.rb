require 'base64'
require 'openssl'
require 'uri'

module Angelo
  module Sessions
    module Crypto

      def cipher mode
        c = OpenSSL::Cipher::AES256.new :CBC
        c.__send__ mode
        c.key = Sessions.store.secret
        c.iv = Sessions.store.secret.reverse[0,16]
        c
      end

      def encrypt s
        c = cipher :encrypt
        URI.encode_www_form_component Base64.encode64(c.update(s) + c.final)
      end

      def decrypt s
        s = Base64.decode64 URI.decode_www_form_component s
        c = cipher :decrypt
        c.update(s) + c.final
      rescue => e
        warn e.message
        STDERR.puts e.backtrace.map {|m| "\t#{m}"}
        nil
      end

    end
  end
end
