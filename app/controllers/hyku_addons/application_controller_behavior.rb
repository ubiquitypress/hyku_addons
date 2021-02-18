# frozen_string_literal: true

module HykuAddons
  module ApplicationControllerBehavior
    extend ActiveSupport::Concern

    included do
      after_action :set_locale

      def set_locale
        I18nMultitenant.set(locale: I18n.locale, tenant: current_account.name)
      end
    end
  end
end
