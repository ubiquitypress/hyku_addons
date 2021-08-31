# frozen_string_literal: true

module HykuAddons
  class PerTenantSmtpInterceptor
    def self.available_smtp_fields
      %w[from user_name password address domain port enable_starttls_auto].freeze
    end

    def self.delivering_email(message)
      Account.find_by(tenant: Apartment::Tenant.current)&.switch!
      return unless (mailer_settings = Settings.smtp_settings.presence)

      if mailer_settings.from.present?
        message.from = mailer_settings.from
        message.reply_to = mailer_settings.from
        message.return_path = mailer_settings.from
      end

      data = (HykuAddons::PerTenantSmtpInterceptor.available_smtp_fields - ['from']).map do |key|
        value = mailer_settings.try(key)
        [key, value] if value.present?
      end
      message.delivery_method.settings.merge! data.compact.to_h
    end
  end
end
