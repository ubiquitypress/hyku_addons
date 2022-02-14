# frozen_string_literal: true

module HykuAddons
  module RegistrationsControllerBehavior
    def new
      return super if current_account&.allow_signup == "true"

      redirect_to root_path, alert: t("hyku.account.signup_disabled")
    end

    def create
      return super if current_account&.allow_signup == "true"

      redirect_to root_path, alert: t("hyku.account.signup_disabled")
    end

    def current_account
      Site.account
    end

    protected

    # Redirect the user to the profile after registration
    def after_sign_up_path_for(resource)
      hyrax.dashboard_profile_path(resource)
    end
  end
end
