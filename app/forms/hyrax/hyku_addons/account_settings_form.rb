module Hyrax
  module HykuAddons
    class AccountSettingsForm
      include ActiveModel::Model
      extend ActiveModel::Callbacks

      attr_accessor :account

      ::HykuAddons::AccountSettingsCollection.all.each do |setting|
        attr_accessor setting
      end

      validates :gtm_id, format: { with: /GTM-[A-Z0-9]{4,7}/, message: "Invalid GTM ID" }, allow_blank: true
      validates :contact_email, :oai_admin_email,
                format: { with: URI::MailTo::EMAIL_REGEXP },
                allow_blank: true
      validate :validate_email_format, :validate_contact_emails

      def initialize(account)
        self.account = account
        self.attributes = account.settings
      end

      def save
        if valid?
          persist!
        else
          false
        end
      end

      def attributes
        Hash[::HykuAddons::AccountSettingsCollection.all.map{ |attr| [attr, self.send(attr)] }]
      end

      def attributes=(attrs)
        attrs.each { |k, v| self.send("#{k}=", v) }
      end

      def persist!
        account.update settings: attributes
      end

      def update_attributes(attrs)
        self.attributes = attrs
        save
      end

      private

      def validate_email_format
        Array.wrap(email_format).each do |email|
          errors.add(:email_format) unless email.match?(/@\S*\.\S*/)
        end
      end

      def validate_contact_emails
        ['weekly_email_list', 'monthly_email_list', 'yearly_email_list'].each do |key|
          Array.wrap(attributes[key]).each do |email|
            errors.add(:"#{key}") unless email.match?(URI::MailTo::EMAIL_REGEXP)
          end
        end
      end
    end
  end
end
