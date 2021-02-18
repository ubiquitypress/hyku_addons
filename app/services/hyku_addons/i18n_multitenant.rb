require "i18n"

module HykuAddons
  module I18nMultitenant
    def self.set(options)
      I18n.locale = locale_for(options)
    end

    def self.with_locale(options)
      I18n.with_locale(locale_for(options)) { yield }
    end

    def self.locale_for(locale: I18n.default_locale, tenant: nil)
      if tenant&.to_s.present?
        "#{locale}-#{tenant.to_s.upcase.tr(' .-', '_')}"
      else
        locale
      end
    end

    def self.configure(config, enforce_available_locales: false)
      config.enforce_available_locales = enforce_available_locales
      config.backend.class.send(:include, I18n::Backend::Fallbacks)

      config.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
    end
  end
end
