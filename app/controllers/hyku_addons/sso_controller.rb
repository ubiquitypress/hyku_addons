# frozen_string_literal: true

module HykuAddons
  class SsoController < ::Hyku::API::V1::SessionsController

    before_action :set_account, only: :callback

    def auth
      redirect_to HykuAddons::Sso::AuthService.new(host: request.host).generate_authorisation_url
    end

    def callback

      service = HykuAddons::Sso::CallBackService.new(code: params[:code],host: request.host)

      handled = false

      service.handle do |profile, password|
        
        user = User.find_or_create_by!(email: profile.email) do |u|
          u.password = password
        end

        sign_in user

        set_jwt_cookies(user)

        handled = true

      end

      raise HykuAddons::Sso::Error, "Failed to handle workos code #{params[:code]}" unless handled

      redirect_to "/dashboard"
      # Use the information in `profile` for further business logic.
    end

    def current_account
      @account ||= Account.find_by cname: request.env["SERVER_NAME"]
    end

    def set_account
      AccountElevator.switch!(current_account.cname) if current_account.present?
    end

  end
end
