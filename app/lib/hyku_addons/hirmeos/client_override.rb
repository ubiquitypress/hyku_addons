# frozen_string_literal: true
require "jwt"

module HykuAddons
  module Hirmeos
    module ClientOverride
      def generate_token(payload = build_payload)
        JWT.encode(payload, @secret)
      end

      private

      def build_payload
        {
          'authority': "user",
          'email': "",
          'exp': 15.minutes.from_now.to_i,
          'iat': Time.now.to_i,
          'name': "",
          'sub': ""
        }
      end

      def connection_for(url)
        Faraday.new(url) do |conn|
          conn.adapter Faraday.default_adapter
          conn.authorization :Bearer, generate_token
        end
      end
    end
  end
end
