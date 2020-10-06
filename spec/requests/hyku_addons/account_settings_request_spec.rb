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
    it "can update a single settings key eg  contact_email" do
      patch update_single_admin_account_setting_url(id: account, partial_name: 'contact_email'), params: { "account" => { "settings" => { "contact_email" => "ab@abc.com" } } }
      expect(response).to redirect_to admin_account_settings_url
      follow_redirect!
    end
  end

  describe "Update all or multiple settings keys" do
    context "update fields" do
      it "can update multiple fields eg contact_email and wekkly_email_list" do
        put admin_account_setting_url(account.id), params: { 'account' => { "settings" => { "contact_email" => "ab@abc.com", "weekly_email_list" => ['we@we.com'] } } }
        expect(response).to redirect_to admin_account_settings_url
        follow_redirect!
      end
    end
  end
end
