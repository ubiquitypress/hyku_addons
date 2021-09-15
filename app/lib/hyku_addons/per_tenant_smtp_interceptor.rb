# frozen_string_literal: true

module HykuAddons
  class PerTenantSmtpInterceptor
    def self.available_smtp_fields
      %w[from from_alias user_name password address domain port authentication enable_starttls_auto].freeze
    end

    def self.delivering_email(message)
      Account.find_by(tenant: Apartment::Tenant.current)&.switch!
      return unless (mailer_settings = Settings.smtp_settings).present?

      mailer_config = configure_mailer_tenant_settings(mailer_settings, message)
      message.delivery_method.settings.merge!(mailer_config.compact.to_h)
    end

    def self.configure_mailer_tenant_settings(mailer_settings, message)
      if (from = mailer_settings.from).present?
        message.from = if (from_alias = mailer_settings.from_alias).present?
                         "#{from_alias} <#{from}>"
                       else
                         from
                       end
        message.reply_to = from
        message.return_path = from
        message.smtp_envelope_from = from
      end

      (HykuAddons::PerTenantSmtpInterceptor.available_smtp_fields - ['from']).map do |key|
        value = mailer_settings.try(key)
        [key.to_sym, value] if value.present?
      end
    end
  end
end
