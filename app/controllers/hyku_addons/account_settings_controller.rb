# frozen_string_literal: true

require_dependency "hyku_addons/application_controller"

module HykuAddons
  class AccountSettingsController < AdminController
    before_action :set_account
    before_action :map_array_fields, only: [:update, :update_single]

    def index; end

    def edit
      puts "RUNNING EDIT"
      # instance variables to pass values to the js.erb files
      @field_name = params[:field_name]
      respond_to do |format|
        format.js { render template: "/hyku_addons/account_settings/settings/#{params[:partial_name]}.js.erb" }
        format.html
      end
    end

    def update
      puts "RUNNING UPDATE"
      @account.update(account_params)
      redirect_to admin_account_settings_path
    end

    def update_single
      puts "RUNNING UPDATE SINGELE"
      @account.settings.merge!(account_params['settings'])
      # removes nil keys in the hash
      @account.settings.compact
      @account.save if @account.settings_changed?
      # redirect_to admin_account_settings_path
    end

    private

      def account_params
        params.require(:account).permit(
          settings: [:contact_email, :index_record_to_shared_search, :live, :enabled_doi, :gtm_id,
                     :turn_off_fedora_collection_work_association, :file_size_limit, :enable_oai_metadata,
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

      def map_array_fields
        ['email_format', 'weekly_email_list', 'monthly_email_list', 'yearly_email_list', 'contributor_roles', 'creator_roles'].each do |key|
          next if params['account']['settings'][key].blank?
          params['account']['settings'][key].map! { |str| str.split(' ') }.flatten!
        end
      end
  end
end
