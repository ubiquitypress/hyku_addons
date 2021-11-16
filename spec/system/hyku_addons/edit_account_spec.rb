# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Proprietor Edit Account Page", type: :system do
  let(:user) { FactoryBot.create(:admin) }
  let(:full_account) { create(:account) }
  let!(:account) { create(:account, search_only: true, full_account_ids: [full_account.id]) }
  let(:routes) { Rails.application.routes.url_helpers }

  before do
    driven_by(:rack_test)
    login_as(user, scope: :user)

    Capybara.default_host = "http://#{account.cname}"
  end

  describe "shared search checkbox" do
    xit "can display checkbox for shared_search" do
      visit routes.edit_proprietor_account_url(account.id)
      expect(find_field(id: "account_search_only")).to be_checked
      expect(page).to have_content("Search only")
    end

    xit "can display add to account text" do
      visit routes.new_proprietor_account_url
      expect(page).to have_content("Add account to search")
    end
  end
end
