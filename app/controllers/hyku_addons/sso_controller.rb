# frozen_string_literal: true

module HykuAddons
  class SsoController < ::Hyku::API::V1::SessionsController

    before_action :set_account, only: :callback

    def auth
      redirect_to HykuAddons::Sso::AuthService.new(account: current_account).generate_authorisation_url
    end

    def uiauth
      account = Account.find_by tenant: params[:tenant_id]
      redirect_to HykuAddons::Sso::AuthService.new(account: account).generate_authorisation_url_for_frontend
    end


    def uicallback

      service = HykuAddons::Sso::CallBackService.new(code: params[:code])

      user = nil

      service.handle do |profile, password|

        user = User.find_or_create_by!(email: profile.email.downcase) do |u|
          u.password = password
        end
        
        sign_in user
        set_jwt_cookies(user)
      end

      raise HykuAddons::Sso::Error, "Failed to handle workos code #{params[:code]}" unless user

      render_user(user)
    end

    def callback

      service = HykuAddons::Sso::CallBackService.new(code: params[:code])

      handled = false

      service.handle do |profile, password|

        user = User.find_or_create_by!(email: profile.email.downcase) do |u|
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
