# frozen_string_literal: true

require_dependency "hyku_addons/application_controller"

module HykuAddons
  class AccountSettingsController < AdminController
    before_action :set_account

    def index; end

    def edit
      # instance variables to pass values to the js.erb files
      @field_name = params[:field_name]
      respond_to do |format|
        format.js { render template: "/hyku_addons/account_settings/settings/#{params[:partial_name]}.js.erb" }
        format.html
      end
    end

    def update
      @account.update(account_params)
      map_array_fields(submitted_hash)
      redirect_to admin_account_settings_path
    end

    def update_single
      submitted_hash = account_params.to_h['settings']
      map_array_fields(submitted_hash)
      hash_key = submitted_hash&.keys&.first || {}
      if hash_key.present?
        # update only the hash key without overriding other content in the original hash
        @account.settings[hash_key] = submitted_hash[hash_key]
        # removes nil keys in the hash
        @account.settings.compact
        @account.save
      end
      redirect_to admin_account_settings_path
    end

    private

      def account_params
        params.require(:account).permit(
          settings: [:contact_email, :index_record_to_shared_search, :live, :enabled_doi, :gtm_id,
                     :turn_off_fedora_collection_work_association,
                     :add_collection_list_form_display, :hide_form_relationship_tab, :shared_login,
                     :email_hint_text, :creator_fields, :contributor_fields, :sign_up_link, :allow_signup,
                     :redirect_on, :institutional_relationship_picklist, :institutional_relationship,
                     email_format: [], help_texts: {}, work_unwanted_fields: {}, work_type_list: [],
                     required_json_property: {}, contributor_roles: [], metadata_labels: {},
                     creator_roles: [], html_required: {}, licence_list: [:name, :url],
                     weekly_email_list: [], monthly_email_list: [], yearly_email_list: []]
        )
      end

      def set_account
        @account = current_account
      end

      def map_array_fields(hash)
        ['email_format', 'weekly_email_list', 'monthly_email_list', 'yearly_email_list', 'contributor_roles', 'creator_roles'].each do |key|
          next if hash[key].blank?
          hash[key].map! { |str| str.split(' ') }.flatten!
        end
      end
  end
end
