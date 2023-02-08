# frozen_string_literal: true

module HykuAddons
  class SsoController < ::Hyku::API::V1::SessionsController
    def auth
      redirect_to HykuAddons::Sso::AuthService.new(host: request.host).generate_authorisation_url
    end

    def callback
      service = HykuAddons::Sso::CallBackService.new(code: params[:code])

      service.handle do | profile, password|
        user = User.find_or_create_by(email: profile.email).tap do |u|
          u.password = password
          u.password_confirmation = password
          u.email = profile.email
        end

        set_jwt_cookies(user)
        sign_in(user)

        redirect_to "/dashboard"
      end

      raise HykuAddons::Sso::Error, "Invalid Code"

      # Use the information in `profile` for further business logic.
    end
  end
end
