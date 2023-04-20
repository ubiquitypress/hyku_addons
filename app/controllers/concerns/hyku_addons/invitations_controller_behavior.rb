# frozen_string_literal: true

module HykuAddons
  module InvitationsControllerBehavior

    def create
      email_domain = params[:user][:email].split("@").last
      managed_domain = Site.account&.work_os_managed_domain

      return super if managed_domain.nil?

      return super if managed_domain != email_domain

      redirect_to request.referer, alert: t("errors.invalid_domain", managed_domain: managed_domain)

    end
  end
end
