# frozen_string_literal: true
require_relative '/lib/hyku_addons/sso'

module HykuAddons
  class SsoController< ::Hyku::API::V1::SessionsController
    def auth  
      redirect_to HykuAddons::Sso::AuthService.new(host: request.host)
        .service.generate_authorisation_url
    end

    def callback

      service = HykuAddons::Sso::CallBackService.new(params: { code: params['code']})

      service.handle do |_profile, _password|
      
        user = User.find_or_create_by(email: profile.email).tap do |u|
          u.password = password
          u.password_confirmation = password
          u.email = profile.email

          sign_in(user)
          set_jwt_cookies(user)

        end

         redirect_to "/dashboard"

      end

      
      raise HykuAddons::Sso::Error.new("Invalid Code")

      # Use the information in `profile` for further business logic.
    end

  end
end

