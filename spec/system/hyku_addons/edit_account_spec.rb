# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Proprietor Edit Account Page', type: :system do
  let(:user) { FactoryBot.create(:admin) }
  let!(:account) { create(:account) }
  let(:routes) { Rails.application.routes.url_helpers }

  before do
    driven_by(:rack_test)
    login_as(user, scope: :user)

    Capybara.default_host = "http://#{account.cname}"
  end

  describe 'shared search checkbox' do
    it 'can display checkbox for shared_search' do
      visit routes.edit_proprietor_account_url
      expect(page).to have_content('Search only')
      expect(find_field(id: 'account_settings_shared_search')).not_to be_checked
    end

    it 'can check shared_search checkbox' do
      visit routes.edit_proprietor_account_url
      check "account[settings][shared_search]"
      expect(find_field(id: 'account_settings_shared_search')).to be_checked
    end
  end
end
