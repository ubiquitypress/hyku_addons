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
      expect(page).to have_content('Account Settings')
      expect(page).to have_selector 'h1', visible: true, text: /Account Settings/
      expect(page).to have_link('Edit email')
    end
  end
end
