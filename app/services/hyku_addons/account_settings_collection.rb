module HykuAddons
  class AccountSettingsCollection
    def self.all
      [:contact_email, :weekly_email_list, :monthly_email_list, :yearly_email_list,
       :index_record_to_shared_search, :google_scholarly_work_types,
       :live, :enabled_doi, :gtm_id, :turn_off_fedora_collection_work_association,
       :add_collection_list_form_display, :hide_form_relationship_tab, :shared_login,
       :work_type_list, :email_hint_text, :email_format, :help_texts, :work_unwanted_fields,
       :required_json_property, :creator_fields, :contributor_fields, :metadata_labels,
       :institutional_relationship_picklist, :institutional_relationship, :contributor_roles,
       :creator_roles, :html_required, :licence_list, :allow_signup, :redirect_on, :oai_admin_email,
       :file_size_limit, :enable_oai_metadata, :oai_prefix, :oai_sample_identifier]
    end
  end
end
