# frozen_string_literal: true
# Customer organization account
module HykuAddons
  module AccountBehavior
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    included do
      belongs_to :datacite_endpoint, dependent: :delete
      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings, :contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
                     :index_record_to_shared_search, :google_scholarly_work_types,
                     :enabled_doi, :gtm_id, :add_collection_list_form_display, :hide_form_relationship_tab, :shared_login,
                     :email_hint_text, :email_format, :help_texts, :work_unwanted_fields,
                     :required_json_property, :creator_fields, :contributor_fields, :metadata_labels,
                     :institutional_relationship_picklist, :institutional_relationship, :contributor_roles,
                     :creator_roles, :html_required, :licence_list, :allow_signup, :redirect_on, :oai_admin_email,
                     :file_size_limit, :enable_oai_metadata, :oai_prefix, :oai_sample_identifier

      accepts_nested_attributes_for :datacite_endpoint, update_only: true
      after_initialize :set_jsonb_help_texts_default_keys, :set_jsonb_work_unwanted_fields_default_keys
      after_initialize :set_jsonb_required_json_property_default_keys, :set_jsonb_html_required_default_keys
      after_initialize :set_jsonb_metadata_labels_default_keys, :set_jsonb_licence_list_default_keys
      after_initialize :set_jsonb_allow_signup_default
      before_save :remove_settings_hash_key_with_nil_value
      validates :gtm_id, format: { with: /GTM-[A-Z0-9]{4,7}/, message: "Invalid GTM ID" }, allow_blank: true
      validates :contact_email, :oai_admin_email,
                format: { with: URI::MailTo::EMAIL_REGEXP },
                allow_blank: true
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

      def set_jsonb_help_texts_default_keys
        return if settings['help_texts'].present?
        self.help_texts = {
          subject: nil, org_unit: nil, refereed: nil, additional_information: nil,
          publisher: nil, volume: nil, pagination: nil, isbn: nil, issn: nil,
          duration: nil, version: nil, keyword: nil
        }
      end

      def set_jsonb_work_unwanted_fields_default_keys
        return if settings['work_unwanted_fields'].present?
        self.work_unwanted_fields = {
          book_chapter: nil, article: nil, news_clipping: nil
        }
      end

      # populate with names of json keys that should be required eg "media": ["creator_institutional_relationship"]
      # means "creator_institutional_relationship" is required for media work_type
      def set_jsonb_required_json_property_default_keys
        return if settings['required_json_property'].present?
        self.required_json_property = { media: [], presentation: [], text_work: [], uncategorized: [],
                                        news_clipping: [], article_work: [], book_work: [],
                                        image_work: [], thesis_or_dissertation_work: [] }
      end

      def set_jsonb_metadata_labels_default_keys
        return if settings['metadata_labels'].present?
        self.metadata_labels = {
          institutional_relationship: nil, family_name: nil, given_name: nil,
          org_unit: nil, version_number: nil
        }
      end

      def set_jsonb_html_required_default_keys
        return if settings['html_required'].present?
        self.html_required = {
          contributor: nil
        }
      end

      def set_jsonb_licence_list_default_keys
        return if settings['licence_list'].present?
        self.licence_list = {
          name: nil, value: nil
        }
      end

      def set_jsonb_allow_signup_default
        return if settings['allow_signup'].present?
        self.allow_signup = 'true'
      end

      def remove_settings_hash_key_with_nil_value
        ['help_texts', 'work_unwanted_fields', 'required_json_property', 'metadata_labels', 'html_required'].each do |key|
          settings[key].delete_if { |_hash_key, value| value.blank? } if settings[key].class == Hash
        end
      end
  end
end
