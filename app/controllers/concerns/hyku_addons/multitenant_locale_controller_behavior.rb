# frozen_string_literal: true

# Overrides Hyrax methods to handle multitenant overrides of I18n locale
module HykuAddons
  module MultitenantLocaleControllerBehavior
    extend ActiveSupport::Concern

    # Ensure that the originally requested locale choice is persistent across requests
    # @override
    def default_url_options
      super.merge(locale: requested_locale)
    end

    private

      # This needs to be run on each request to properly set the correct lang file and fallback
      # which is why the complicated logic for deciding the current locale is inside of hyku_addon_locale
      #
      # URL: http://repo.hyku.docker/admin/account_settings?locale=en
      # locale: "en-REPO"
      #
      # NOTE:
      # See `I18n.fallbacks` for the registered fallback locales
      # @override
      def set_locale
        I18nMultitenant.set(locale: requested_locale, tenant: current_locale_name)
      end

      def requested_locale
        params[:locale] || I18n.default_locale
      end

      # NOTE: The settings value can be "" or nil, so use `presence` if checking present?
      def current_locale_name
        current_account&.settings&.dig("locale_name")
      end
  end
end
