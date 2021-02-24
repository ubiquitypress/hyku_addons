# frozen_string_literal: true

require "i18n"

# Adapted from https://github.com/ElMassimo/i18n_multitenant/blob/master/lib/i18n_multitenant.rb
module HykuAddons
  module I18nMultitenant
    # Ensure Fallbacks are configured
    def self.configure(config, enforce_available_locales: false)
      config.enforce_available_locales = enforce_available_locales
      config.backend.class.send(:include, I18n::Backend::Fallbacks)
    end

    def self.set(options)
      I18n.locale = locale_for(options)
    end

    # Execute block in the desired locale and retore
    def self.with_locale(options)
      I18n.with_locale(locale_for(options)) { yield }
    end

    # Calculate the locale for the current request and return a string
    def self.locale_for(locale: I18n.default_locale, tenant: nil)
      if tenant&.to_s.present?
        "#{locale}-#{processed_tenant(tenant)}"
      else
        locale
      end
    end

    def self.processed_tenant(tenant)
      tenant.to_s.upcase.tr(' .-', '_')
    end
  end
end
