# frozen_string_literal: true
require "securerandom"
require "ostruct"
# Sso login for the hyku reposiory

module HykuAddons

  module Sso
    class << self
      # Initialization of workos
      def initialize
        WorkOS.configure do |config|
          config.key = configuration.api_key
          config.timeout = 120
        end
      end

      # Instantiate the Configuration singleton
      # or return it. Remember that the instance
      # has attribute readers so that we can access
      # the configured values
      def configuration
        @configuration ||= OpenStruct.new
      end

      # This is the configure block definition.
      # The configuration method will return the
      # Configuration singleton, which is then yielded
      # to the configure block. Then it's just a matter
      # of using the attribute accessors we previously defined
      def configure
        initialize
        configuration.api_key = ENV["WORKOS_API_KEY"]
        configuration.client_id = ENV["WORKOS_CLIENT_ID"]
        configuration.organisation_id = ENV["ORGANISATION_ID"]
        yield(configuration)
      end
    end
    class Error < StandardError; end

    # The auth service is responsbible for generating the workos redirect url.
    class AuthService
      def initialize(host:)
        @host = host
      end

      def generate_authorisation_url
        # The callback URI WorkOS should redirect to after the authentication
        redirect_uri = "https://#{@host}/sso/callback"

        WorkOS::SSO.authorization_url(
          client_id: Sso.configuration.client_id,
          organization: Sso.configuration.organisation_id,
          redirect_uri: redirect_uri
        )
      end
    end

    # The call back service handles the repsose back from workos
    class CallBackService
      def initialize(params:)
        @params = params
      end

      def handle
        profile_and_token = WorkOS::SSO.profile_and_token(
          code: @params["code"],
          client_id: Sso.configuration.client_id
        )

        password = SecureRandom.hex(10)
        profile = profile_and_token.profile

        yield(profile, password) if block_given?
      end
    end
  end
end
