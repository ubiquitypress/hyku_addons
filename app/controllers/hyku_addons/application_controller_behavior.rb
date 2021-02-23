# frozen_string_literal: true

module HykuAddons
  module ApplicationControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :set_locale

      # This needs to be run on each request to properly set the correct lang file and fallback
      # which is why the complicated logic for deciding the current locale is inside of hyku_addon_locale
      #
      # URL: http://repo.lvh.me:3000/admin/account_settings?locale=en
      # locale: "en-REPO"
      #
      # URL: http://repo.lvh.me:3000/admin/account_settings?locale=en-REPO
      # locale: "en-REPO"
      #
      # NOTE:
      # See `I18n.fallbacks` for the registered fallback locales
      def set_locale
        I18nMultitenant.set(locale: hyku_addon_locale, tenant: current_account.name)
      end

      # Try and stop the locales being stacked up when Hyku adds them to every URL
      # which will cause them to end up like: "?locale=en-REPO-REPO-REPO"
      def hyku_addon_locale
        @_hyku_addon_locale ||= begin
          processed_tenant = HykuAddons::I18nMultitenant.processed_tenant(current_account.name)
          current = (params.dig("locale") || I18n.default_locale)

          # If we the tenant is already in the URL, then strip it out and return just the language part
          return (current.to_s.split("-") - [processed_tenant]).join("-").to_sym if current.to_s.include?(processed_tenant)

          current.to_sym
        end
      end
    end
  end
end
