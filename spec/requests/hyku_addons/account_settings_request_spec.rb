# frozen_string_literal: true
require "rails_helper"

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

  describe "GET /admin/account_settings" do
    it "GETS index  /admin/account_settings" do
      get admin_account_settings_url
      expect(response).to have_http_status(:ok)
    end
  end

  describe "Update single keys in settings hash" do
    context "can display edit page" do
      it "GET text_field edit page" do
        get edit_admin_account_setting_url(id: account, partial_name: "render_text_fields", field_name: "contact_email")
        expect(response).to have_http_status(:ok)
      end

      it "GET array edit page" do
        get edit_admin_account_setting_url(id: account, partial_name: "render_array_list", field_name: "weekly_email_list")
        expect(response).to have_http_status(:ok)
      end

      it "GET boolean_field edit page" do
        get edit_admin_account_setting_url(id: account, partial_name: "render_single_boolean", field_name: "shared_login")
        expect(response).to have_http_status(:ok)
      end
    end

    context "can update a single key" do
      it "can update a single settings key eg  contact_email" do
        patch update_single_admin_account_setting_url(id: account), params: { "account" => { "settings" => { "contact_email" => "bo@abc.com" } } }
        account.reload
        expect(account.settings["contact_email"]).to eq "bo@abc.com"
        expect(response).to redirect_to admin_account_settings_url
      end
    end
  end

  describe "Update all or multiple settings keys" do
    context "update fields" do
      it "can update multiple fields eg contact_email and weekly_email_list" do
        put admin_account_setting_url(account.id), params: { "account" => { "settings" => { "contact_email" => "ta@abc.com", "weekly_email_list" => ["we@we.com"] } } }
        account.reload
        expect(account.settings["contact_email"]).to eq "ta@abc.com"
        expect(account.settings["weekly_email_list"]).to include("we@we.com")
        expect(response).to redirect_to admin_account_settings_url
      end
    end
  end

  describe "updating settings moved from environment variables" do
    context "boolean keys" do
      it "can set booleans setting keys to false" do
        boolean_keys = [["allow_signup", false], ["shared_login", false]]
        boolean_hash = Hash[*boolean_keys.flatten]
        put admin_account_setting_url(account.id), params: { "account" => { "settings" => boolean_hash } }
        account.reload
        ["allow_signup", "shared_login"].each do |key|
          expect(account.settings[key]).to eq "false"
        end
        expect(response).to redirect_to admin_account_settings_url
      end

      it "can set booleans setting keys to true" do
        boolean_keys = [["allow_signup", true]]
        boolean_hash = Hash[*boolean_keys.flatten]
        put admin_account_setting_url(account.id), params: { "account" => { "settings" => boolean_hash } }
        account.reload
        ["allow_signup"].each do |key|
          expect(account.settings[key]).to be_truthy
        end
        expect(response).to redirect_to admin_account_settings_url
      end
    end
  end
end
