# frozen_string_literal: true

module HykuAddons
  module RegistrationsControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :check_allowed_signup
    end

    private

    def check_allowed_signup
      if current_account.settings['allow_signup'] == "false"
        puts "IN THE IF"
        redirect_to root_path, alert: t(:'hyku.account.signup_disabled')
        return
      end
    end
  end
end
