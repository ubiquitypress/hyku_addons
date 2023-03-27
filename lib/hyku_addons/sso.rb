# frozen_string_literal: true
require "workos"
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
        configuration.api_key = ENV["WORKOS_API_KEY"]
        configuration.client_id = ENV["WORKOS_CLIENT_ID"]
        initialize
        yield(configuration)
      end
    end
    class Error < StandardError; end

    # The auth service is responsbible for generating the workos redirect url.
    class AuthService
      def initialize(account:)
        @account = account
      end

      def generate_authorisation_url_for_frontend
        # The callback URI WorkOS should redirect to after the authentication
        WorkOS::SSO.authorization_url(
          client_id: Sso.configuration.client_id,
          organization: @account.work_os_organisation,
          redirect_uri: "https://#{@account.cname.gsub(".dashboard","")}/sso/callback" 
        )
      end

      def generate_authorisation_url
        # The callback URI WorkOS should redirect to after the authentication
        WorkOS::SSO.authorization_url(
          client_id: Sso.configuration.client_id,
          organization: @account.work_os_organisation,
          redirect_uri: "https://#{@account.cname}/sso/callback" 
        )
      end
    end

    # The call back service handles the repsose back from workos
    class CallBackService
      def initialize(code:)
        @code = code
      end

      def handle
        profile_and_token = WorkOS::SSO.profile_and_token(
          code: @code,
          client_id: Sso.configuration.client_id
        )

        password = SecureRandom.hex(10)
        profile = profile_and_token.profile

        yield(profile, password) if block_given?
      end
    end
  end
end
