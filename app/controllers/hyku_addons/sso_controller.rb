# frozen_string_literal: true

module HykuAddons
  class SsoController < ::Hyku::API::V1::SessionsController
    
    before_action :load_account, only: :callback

    def auth
      redirect_to HykuAddons::Sso::AuthService.new(host: request.host).generate_authorisation_url
    end

    def callback
      service = HykuAddons::Sso::CallBackService.new(code: params[:code])

      handled = false

      service.handle do |profile, password|
        user = User.find_or_create_by(email: profile.email).tap do |u|
          u.password = password
          u.password_confirmation = password
          u.email = profile.email
        end

        # this code is the same as the code used in the api for authentication
        user = User.find_for_database_authentication(email: user.email)
        sign_in user
        handled = true
      end

      raise HykuAddons::Sso::Error, "Failed to handle workos code #{params[:code]}" unless handled

      redirect_to "/dashboard"
      # Use the information in `profile` for further business logic.
    end
  end
end
