# frozen_string_literal: true
# Customer organization account
module HykuAddons
  module AccountBehavior
    extend ActiveSupport::Concern
    included do
      belongs_to :datacite_endpoint, dependent: :delete
      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings, :contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
                     :index_record_to_shared_search, :google_scholarly_work_types,
                     :live, :enabled_doi, :gtm_id, :demo_gtm_id, :turn_off_fedora_collection_work_association,
                     :add_collection_list_form_display, :hide_form_relationship_tab, :shared_login,
                     :work_type_list, :email_hint_text, :email_format, :help_texts, :work_unwanted_fields,
                     :required_json_property, :creator_fields, :contributor_fields, :metadata_labels,
                     :institutional_relationship_picklist, :institutional_relationship, :contributor_roles,
                     :creator_roles, :html_required, :licence_list, :sign_up_link, :allow_signup, :redirect_on

      accepts_nested_attributes_for :datacite_endpoint, update_only: true
    end

    def datacite_endpoint
      super || NilDataCiteEndpoint.new
    end
  end
end
