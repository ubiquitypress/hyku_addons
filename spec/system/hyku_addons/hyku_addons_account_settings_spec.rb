# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AccountSettings', type: :system do
  let(:user) { FactoryBot.create(:admin) }
  let!(:account) { create(:account) }
  before do
    driven_by(:rack_test)
    login_as(user, scope: :user)

    allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
      block.call
    end
    account.switch!
  end

  describe 'Account settings index page' do
    it 'can display various edit links' do
      visit hyku_addons.admin_account_settings_url
      expect(page).to have_selector('h1')
      expect(page).to have_selector 'h1', visible: true, text: /Account Settings/
      expect(page).to have_link('Edit contact_email')
    end

    it "can display single text field for edit" do
      visit hyku_addons.edit_admin_account_setting_url(id: account, partial_name: 'render_text_fields', field_name: 'contact_email')
      expect(page).to have_http_status(:ok)
      expect(page).to have_css("label", text: "Contact email")
    end

    it "can display single array field for edit" do
      visit hyku_addons.edit_admin_account_setting_url(id: account, partial_name: 'render_array_list', field_name: 'weekly_email_list')
      expect(page).to have_http_status(:ok)
      expect(page).to have_css("label", text: "Weekly email list")
    end

    it "can display single boolean field for edit" do
      visit hyku_addons.edit_admin_account_setting_url(id: account, partial_name: 'render_single_boolean', field_name: 'enabled_doi')
      expect(page).to have_http_status(:ok)
      expect(page).to have_css("label", text: "Enabled DOI")
    end
  end

  describe 'Single settings key' do
    context "Display in-place edit form for single key" do
      it 'Display in-place edit' do
        visit hyku_addons.edit_admin_account_setting_url(id: account.id, partial_name: 'contact_email')
        expect(page).to have_content('email')
        expect(find_field('account[settings][contact_email]').value).to eq account.settings['contact_email']
        expect(page).to have_link('Back')
        expect(page).to have_selector(:link_or_button, 'Save changes')
      end
    end

    context "Update single settings key" do
      it 'save contact_email' do
        visit hyku_addons.edit_admin_account_setting_url(id: account.id, partial_name: 'contact_email')
        expect(find_field('account[settings][contact_email]').value).to eq account.settings['contact_email']
        find_field('account[settings][contact_email]').set 'do@do.com'
        click_button 'Save changes'
        account.reload
        expect(account.settings['contact_email']).to eq('do@do.com')
      end
    end
  end

  describe "Multiple settings Edit" do
    context "Display page for all settings" do
      it "Can visit page to edit multiple setting keys" do
        visit hyku_addons.admin_account_settings_url
        click_on 'Edit all fields'
        expect(page).to have_content('Editing Account Settings')
        expect(page).to have_link('Back')
        expect(page).to have_selector(:link_or_button, 'Save changes')
      end
    end

    context "Update multiple settings keys" do
      it "can save multiple settings keys" do
        visit hyku_addons.admin_account_settings_url
        click_on 'Edit all fields'
        find_field('account[settings][contact_email]').set 'do@do.com'
        find_field('account[settings][weekly_email_list][]').set 'wema@we.yahoo.com;ba@bl.uk'
        click_button 'Save changes'
        account.reload
        expect(account.settings['contact_email']).to eq('do@do.com')
        expect(account.settings['weekly_email_list']).to eq ['wema@we.yahoo.com;ba@bl.uk']
      end
    end
  end
end
