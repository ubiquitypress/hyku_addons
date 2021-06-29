# frozen_string_literal: true

module HykuAddons
  class PerTenantSmtpInterceptor
    def self.delivering_email(message)
      Account.find_by(tenant: Apartment::Tenant.current)&.switch!
      return unless (mailer_settings = Settings.action_mailer.presence)

      message.from = mailer_settings.from if mailer_settings.from.present?
      dynamic_settings = Settings.action_mailer.smtp_settings
      message.delivery_method.settings.merge!(dynamic_settings) if dynamic_settings.present?
    end
  end
end
