# frozen_string_literal: true
require "rails_helper"

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature "Create an Admin Set", js: false, clean: true do
  let(:user_attributes) do
    { email: "test@example.com" }
  end
  let(:user) do
    User.new(user_attributes) { |u| u.save(validate: false) }
  end

  before do
    Hyrax::CollectionTypes::CreateService.create_admin_set_type
    login_as user
  end

  it "creates an admin set" do
    # Go directly to the admin sets new form
    visit "/admin/admin_sets/new"

    # Title
    fill_in("Title", with: "My Test Admin Set")

    click_button "Save"

    visit page.current_path.sub("/edit", "")

    expect(page).to have_content("My Test Admin Set")
  end
end
