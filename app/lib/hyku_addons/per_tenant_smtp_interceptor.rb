# frozen_string_literal: true

module HykuAddons
  class PerTenantSmtpInterceptor
    def self.delivering_email(message)
      account = Account.find_by(tenant: Apartment::Tenant.current)
      account.switch!

      mailer_settings = Settings.action_mailer.smtp_settings
      return unless mailer_settings.present?
      message.from = mailer_settings.from if mailer_settings.from

      dynamic_settings = Settings.action_mailer.smtp_settings
      message.delivery_method.settings.merge!(dynamic_settings) if dynamic_settings
    end
  end
end
