# frozen_string_literal: true

# Customer organization account
module HykuAddons
  module AccountBehavior
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    ARRAY_SETTINGS = %w[weekly_email_list monthly_email_list yearly_email_list email_format].freeze
    SEARCHABLE_SELECT_SETTINGS = %w[doi_list].freeze
    BOOLEAN_SETTINGS = %w[allow_signup shared_login bulkrax_validations].freeze
    HASH_SETTINGS = %w[smtp_settings hyrax_orcid_settings].freeze
    HASH_DROPDOWN_SETTINGS = %w[crossref_hyku_mappings].freeze
    TEXT_SETTINGS = %w[contact_email gtm_id oai_admin_email oai_prefix oai_sample_identifier google_analytics_id].freeze
    TEXT_AREA_SETTINGS = %w[gds_reports].freeze

    PRIVATE_SETTINGS = %w[smtp_settings].freeze

    # rubocop:disable Metrics/BlockLength
    included do
      # added forshared search
      scope :full_accounts, -> { where(search_only: false) }

      has_many :full_account_cross_searches, class_name: "AccountCrossSearch", dependent: :destroy, foreign_key: "search_account_id"
      has_many :full_accounts, class_name: "Account", through: :full_account_cross_searches
      has_many :search_account_cross_searches, class_name: "AccountCrossSearch", dependent: :destroy, foreign_key: "full_account_id"
      has_many :search_accounts, class_name: "Account", through: :search_account_cross_searches
      accepts_nested_attributes_for :full_accounts
      accepts_nested_attributes_for :full_account_cross_searches, allow_destroy: true

      belongs_to :datacite_endpoint, dependent: :delete
      accepts_nested_attributes_for :datacite_endpoint, update_only: true

      store_accessor :data
      store_accessor :settings, :contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
                     :google_scholarly_work_types, :gtm_id, :shared_login, :email_format, :doi_list,
                     :allow_signup, :oai_admin_email, :file_size_limit, :enable_oai_metadata, :oai_prefix,
                     :oai_sample_identifier, :locale_name, :bulkrax_validations, :google_analytics_id, :smtp_settings,
                     :hyrax_orcid_settings, :crossref_hyku_mappings, :gds_reports

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
        setup_tenant_cache(cache_api?)
        switch_hyrax_orcid_credentials!
      end

      def reset!
        setup_tenant_cache(cache_api?)
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

      def setup_tenant_cache(is_enabled)
        Rails.application.config.action_controller.perform_caching = is_enabled
        ActionController::Base.perform_caching = is_enabled

        if is_enabled
          redis_config = { url: ENV["REDIS_URL"], namespace: redis_endpoint.options["namespace"] }
          Rails.application.config.cache_store = :redis_cache_store, redis_config
        else
          Rails.application.config.cache_store = :file_store, Settings.cache_filesystem_root
        end

        Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)
      end

      def cache_api?
        Flipflop.enabled?(:cache_api) && !redis_endpoint.is_a?(NilRedisEndpoint)
      rescue ActiveRecord::StatementInvalid
        true
      end
    end
    # rubocop:enable Metrics/BlockLength

    def datacite_endpoint
      super || NilDataCiteEndpoint.new
    end

    def public_settings
      settings.reject { |k, _v| Account.private_settings.include?(k.to_s) }
    end

    def shared_search_enabled?
      Flipflop.enabled?(:cross_tenant_shared_search)
    end

    private

    def validate_email_format
      return if settings["email_format"].blank?

      settings["email_format"].each do |email|
        errors.add(:email_format) unless email.match?(/@\S*\.\S*/)
      end
    end

    def validate_contact_emails
      ["weekly_email_list", "monthly_email_list", "yearly_email_list"].each do |key|
        next if settings[key].blank?

        settings[key].each do |email|
          errors.add(:"#{key}") unless email.match?(URI::MailTo::EMAIL_REGEXP)
        end
      end
    end

    def initialize_settings
      set_jsonb_allow_signup_default
      set_smtp_settings
      set_hyrax_orcid_settings
      set_crossref_hyku_mappings
    end

    def set_crossref_hyku_mappings
      default_mappings = { "book_section" => "", "monograph" => "", "report_component" => "", "report" => "",
                           "peer_review" => "", "book_track" => "", "journal_article" => "", "book_part" => "",
                           "other" => "", "book" => "", "journal_volume" => "", "book_set" => "", "reference_entry" => "",
                           "proceedings_article" => "", "journal" => "", "component" => "", "book_chapter" => "",
                           "proceedings_series" => "", "report_series" => "", "proceedings" => "", "database" => "",
                           "standard" => "", "reference_book" => "", "posted_content" => "", "journal_issue" => "",
                           "dissertation" => "", "grant" => "", "dataset" => "", "book_series" => "", "edited_book" => "",
                           "default" => "" }

      self.crossref_hyku_mappings = default_mappings.merge(crossref_hyku_mappings || {})
    end

    def set_jsonb_allow_signup_default
      return if settings["allow_signup"].present?

      self.allow_signup = "true"
    end

    def set_smtp_settings
      current_smtp_settings = settings["smtp_settings"].presence || {}

      self.smtp_settings = current_smtp_settings.with_indifferent_access.reverse_merge!(
        HykuAddons::PerTenantSmtpInterceptor.available_smtp_fields.each_with_object("").to_h
      )
    end

    # If any settings are added, also add the param inside HykuAddons::AccountSettingsController
    def set_hyrax_orcid_settings
      orcid_defaults = { "client_id" => "", "client_secret" => "", "auth_redirect" => "", "environment" => "sandbox" }

      self.hyrax_orcid_settings = orcid_defaults.merge(hyrax_orcid_settings || {})
    end

    def switch_hyrax_orcid_credentials!
      return if (orcid = settings["hyrax_orcid_settings"]).blank?

      Hyrax::Orcid.configure do |config|
        config.environment = orcid["environment"]

        config.auth = {
          client_id: orcid["client_id"],
          client_secret: orcid["client_secret"],
          redirect_url: orcid["auth_redirect"]
        }
      end
    end
  end
end
