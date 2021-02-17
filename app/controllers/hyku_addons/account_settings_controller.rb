# frozen_string_literal: true

require_dependency "hyku_addons/application_controller"

module HykuAddons
  class AccountSettingsController < AdminController
    before_action :set_account
    before_action :map_array_fields, only: [:update, :update_single]

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
      redirect_to admin_account_settings_path
    end

    def update_single
      @account.settings.merge!(account_params['settings'])
      # removes nil keys in the hash
      @account.settings.compact
      @account.save if @account.settings_changed?
      redirect_to admin_account_settings_path
    end

    private

      def account_params
        params.require(:account).permit(
          settings: [:contact_email, :gtm_id, :file_size_limit, :enable_oai_metadata,
                     :hide_form_relationship_tab, :shared_login,
                     :redirect_on, :institutional_relationship,
                     :oai_prefix, :oai_sample_identifier, :oai_admin_email, :allow_signup,
                     email_format: [],  weekly_email_list: [], monthly_email_list: [], yearly_email_list: []]
        )
      end

      def set_account
        @account = current_account
      end

      def map_array_fields
        keys = %w[email_format weekly_email_list monthly_email_list yearly_email_list]
        keys.each do |key|
          next if params['account']['settings'][key].blank?
          params['account']['settings'][key].map! { |str| str.split(' ') }.flatten!
        end
      end
  end
end
