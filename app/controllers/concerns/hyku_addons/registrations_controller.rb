# frozen_string_literal: true

module HykuAddons
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters
    def new
      return super if current_account.settings['allow_signup']
      redirect_to root_path, alert: t(:'hyku.account.signup_disabled')
    end

    def create
      return super if current_account.settings['allow_signup']
      redirect_to root_path, alert: t(:'hyku.account.signup_disabled')
    end

    private

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:display_name])
      end
  end
end
