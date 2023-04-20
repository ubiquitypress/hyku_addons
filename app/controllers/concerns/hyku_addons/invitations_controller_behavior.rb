# frozen_string_literal: true

module HykuAddons
  module InvitationsControllerBehavior

    def create
      email_domain = params[:user][:email].split("@").last
      managed_domain = Site.account&.work_os_managed_domain

      if managed_domain == email_domain
        redirect_to request.referer, alert: "Email domain must not be equal to WorkOs managed domain:  #{managed_domain}"
      else
        super
      end
    end
  end
end
