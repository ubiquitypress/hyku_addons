# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "::HykuAddons::AccountSettingsController", type: :request do
  let(:user) { FactoryBot.create(:admin) }
  let!(:account) { create(:account) }
  before do
    login_as(user, scope: :user)
    allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
      block.call
    end
    account.switch!
  end

  after do
    account.reset!
  end

  describe 'GET /admin/account_settings' do
    it "GETS index  /admin/account_settings" do
      get admin_account_settings_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "Update single keys in settings hash" do
    context "can display edit page" do
      it "GET text_field edit page" do
        get edit_admin_account_setting_url(id: account, partial_name: 'render_text_fields', field_name: 'contact_email')
        expect(response).to have_http_status(:ok)
      end

      it "GET array edit page" do
        get edit_admin_account_setting_url(id: account, partial_name: 'render_array_list', field_name: 'weekly_email_list')
        expect(response).to have_http_status(:ok)
      end

      it "GET boolean_field edit page" do
        get edit_admin_account_setting_url(id: account, partial_name: 'render_single_boolean', field_name: 'enabled_doi')
        expect(response).to have_http_status(:ok)
      end
    end

    context "can update a single key" do
      it "can update a single settings key eg  contact_email" do
        patch update_single_admin_account_setting_url(id: account), params: { "account" => { "settings" => { "contact_email" => "bo@abc.com" } } }
        account.reload
        expect(account.settings['contact_email']).to eq 'bo@abc.com'
        expect(response).to redirect_to admin_account_settings_url
      end
    end
  end

  describe "Update all or multiple settings keys" do
    context "update fields" do
      it "can update multiple fields eg contact_email and weekly_email_list" do
        put admin_account_setting_url(account.id), params: { 'account' => { "settings" => { "contact_email" => "ta@abc.com", "weekly_email_list" => ['we@we.com'] } } }
        account.reload
        expect(account.settings['contact_email']).to eq 'ta@abc.com'
        expect(account.settings['weekly_email_list']).to include('we@we.com')
        expect(response).to redirect_to admin_account_settings_url
      end
    end
  end

  describe "updating settings moved from environment variables" do
    context "boolean keys" do
      it "can set booleans setting keys to false" do
        boolean_keys = [['redirect_on', false], ['allow_signup', false],
                        ["hide_form_relationship_tab", false], ["shared_login", false], ["turn_off_fedora_collection_work_association", false]]
        boolean_hash = Hash[*boolean_keys.flatten]
        put admin_account_setting_url(account.id), params: { 'account' => { "settings" => boolean_hash } }
        account.reload
        ['redirect_on', 'allow_signup', "hide_form_relationship_tab",
         "shared_login", "turn_off_fedora_collection_work_association"].each do |key|
          expect(account.settings[key]).to eq 'false'
        end
        expect(response).to redirect_to admin_account_settings_url
      end

      it "can set booleans setting keys to true" do
        boolean_keys = [['enabled_doi', true], ['institutional_relationship_picklist', true]]
        boolean_hash = Hash[*boolean_keys.flatten]
        put admin_account_setting_url(account.id), params: { 'account' => { "settings" => boolean_hash } }
        account.reload
        ['enabled_doi', 'institutional_relationship_picklist'].each do |key|
          expect(account.settings[key]).to be_truthy
        end
        expect(response).to redirect_to admin_account_settings_url
      end

      it "can update licence_list an array of hash" do
        patch update_single_admin_account_setting_url(account.id), params: { 'account' => { 'settings' => { 'licence_list' => [{ name: "new licence",
                                                                                                                                 url: "https://creativecommons.org/licenses/by/4.0/" }] } } }
        account.reload
        expect(account.settings['licence_list'].first).to include('name' => 'new licence')
        expect(response).to redirect_to admin_account_settings_url
      end

      it "can update html_required a hash" do
        patch update_single_admin_account_setting_url(account.id), params: { 'account' => { 'settings' => { 'html_required' => { "contributor" => true } } } }
        account.reload
        expect(account.settings['html_required']).to include("contributor" => 'true')
      end
    end
  end
end
