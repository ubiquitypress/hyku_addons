# frozen_string_literal: true

# Customer organization account
module HykuAddons
  module AccountBehavior
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    ARRAY_SETTINGS = %w[weekly_email_list monthly_email_list yearly_email_list email_format].freeze
    BOOLEAN_SETTINGS = %w[allow_signup shared_login bulkrax_validations].freeze
    HASH_SETTINGS = %w[smtp_settings].freeze
    TEXT_SETTINGS = %w[contact_email gtm_id oai_admin_email oai_prefix oai_sample_identifier google_analytics_id].freeze

    PRIVATE_SETTINGS = %w[smtp_settings].freeze

    included do
      belongs_to :datacite_endpoint, dependent: :delete
      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings, :contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
                     :google_scholarly_work_types, :gtm_id, :shared_login, :email_format,
                     :allow_signup, :oai_admin_email, :file_size_limit, :enable_oai_metadata, :oai_prefix,
                     :oai_sample_identifier, :locale_name, :bulkrax_validations, :google_analytics_id, :smtp_settings

      accepts_nested_attributes_for :datacite_endpoint, update_only: true
      after_initialize :initialize_settings
      validates :gtm_id, format: { with: /GTM-[A-Z0-9]{4,7}/, message: "Invalid GTM ID" }, allow_blank: true
      validates :contact_email, :oai_admin_email,
                format: { with: URI::MailTo::EMAIL_REGEXP },
                allow_blank: true
      validates :tenant, format: { with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/ }
      validate :validate_email_format, :validate_contact_emails
      validates :google_analytics_id,
                format: { with: /((UA|YT|MO)-\d+-\d+|G-[A-Z0-9]{10})/i },
                allow_blank: true

      def self.private_settings
        PRIVATE_SETTINGS
      end

      # @return [Account] a placeholder account using the default connections configured by the application
      def self.single_tenant_default
        Account.new do |a|
          a.build_solr_endpoint
          a.build_fcrepo_endpoint
          a.build_redis_endpoint
          a.build_datacite_endpoint
        end
      end

      # Make all the account specific connections active
      def switch!
        solr_endpoint.switch!
        fcrepo_endpoint.switch!
        redis_endpoint.switch!
        datacite_endpoint.switch!
        Settings.switch!(name: locale_name, settings: settings)
        switch_host!(cname)
        setup_tenant_cache
      end

      def reset!
        disable_tenant_cache
        SolrEndpoint.reset!
        FcrepoEndpoint.reset!
        RedisEndpoint.reset!
        DataCiteEndpoint.reset!
        Settings.switch!
        switch_host!(nil)
      end

      def switch_host!(cname)
        Rails.application.routes.default_url_options[:host] = cname
        Hyrax::Engine.routes.default_url_options[:host] = cname
      end

      def setup_tenant_cache
        Rails.application.config.action_controller.perform_caching = api_cache?
        ActionController::Base.perform_caching = api_cache?

        Rails.application.config.cache_store = :redis_cache_store, { url: Redis.current.id }
        Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)
      end

      def disable_tenant_cache
        Rails.application.config.action_controller.perform_caching = api_cache?
        ActionController::Base.perform_caching = api_cache?

        Rails.application.config.cache_store = :file_store, Settings.cache_filesystem_root
        Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)
      end

      def api_cache?
        Flipflop.enabled?(:cache_api)
      end
    end

    def datacite_endpoint
      super || NilDataCiteEndpoint.new
    end

    def public_settings
      settings.reject { |k, _v| Account.private_settings.include?(k.to_s) }
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

      def initialize_settings
        set_jsonb_allow_signup_default
        set_smtp_settings
      end

      def set_jsonb_allow_signup_default
        return if settings['allow_signup'].present?
        self.allow_signup = 'true'
      end

      def set_smtp_settings
        current_smtp_settings = settings["smtp_settings"].presence || {}
        self.smtp_settings = current_smtp_settings.with_indifferent_access.reverse_merge!(
          HykuAddons::PerTenantSmtpInterceptor.available_smtp_fields.each_with_object("").to_h
        )
      end
  end
end
