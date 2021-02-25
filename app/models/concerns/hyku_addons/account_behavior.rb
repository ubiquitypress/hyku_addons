# frozen_string_literal: true

# Customer organization account
module HykuAddons
  module AccountBehavior
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    ARRAY_SETTINGS = ['weekly_email_list', 'monthly_email_list', 'yearly_email_list', 'email_format'].freeze
    BOOLEAN_SETTINGS = ['redirect_on', 'allow_signup', "shared_login"].freeze
    HASH_SETTINGS = [].freeze
    TEXT_SETTINGS = ['contact_email', 'gtm_id', 'oai_admin_email', 'oai_prefix', 'oai_sample_identifier'].freeze

    included do
      belongs_to :datacite_endpoint, dependent: :delete
      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings, :contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
                     :google_scholarly_work_types, :gtm_id, :shared_login, :email_format,
                     :allow_signup, :redirect_on, :oai_admin_email,
                     :file_size_limit, :enable_oai_metadata, :oai_prefix, :oai_sample_identifier

      accepts_nested_attributes_for :datacite_endpoint, update_only: true
      after_initialize :set_jsonb_allow_signup_default
      validates :gtm_id, format: { with: /GTM-[A-Z0-9]{4,7}/, message: "Invalid GTM ID" }, allow_blank: true
      validates :contact_email, :oai_admin_email,
                format: { with: URI::MailTo::EMAIL_REGEXP },
                allow_blank: true
      validates :tenant, format: { with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/ }
      validate :validate_email_format, :validate_contact_emails
    end

    def datacite_endpoint
      super || NilDataCiteEndpoint.new
    end

    private

      def validate_email_format
        return unless settings['email_format'].present?
        settings['email_format'].each do |email|
          errors.add(:email_format) unless email.match?(/@\S*\.\S*/)
        end
      end

      def validate_contact_emails
        ['weekly_email_list', 'monthly_email_list', 'yearly_email_list'].each do |key|
          next unless settings[key].present?
          settings[key].each do |email|
            errors.add(:"#{key}") unless email.match?(URI::MailTo::EMAIL_REGEXP)
          end
        end
      end

      def set_jsonb_allow_signup_default
        return if settings['allow_signup'].present?
        self.allow_signup = 'true'
      end
  end
end
