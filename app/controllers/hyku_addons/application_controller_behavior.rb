# frozen_string_literal: true

module HykuAddons
  module ApplicationControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :set_locale

      # NOTE:
      # I'm not sure the best `tenant` suffix to inject here to be sure it won't conflict with other users
      # and make sure that its not too restrictive.
      #
      # For the following URL: http://repo.lvh.me:3000/admin/account_settings?locale=en
      # outputs: "en-REPO"
      #
      # `locale` cannot be set using `I18n.locale` or caching will cause the locales to stack up like: "en-REPO-REPO"
      def set_locale
        processed = HykuAddons::I18nMultitenant.processed_tenant(current_account.name)

        # Try and stop the locales being stacked up when Hyku adds them to every URL
        unless current_locale.to_s.include?(processed)
          I18nMultitenant.set(locale: current_locale, tenant: current_account.name)
        end
      end

      def current_locale
        @_current_locale ||= (params.dig("locale") || I18n.default_locale).to_sym
      end
    end
  end
end
