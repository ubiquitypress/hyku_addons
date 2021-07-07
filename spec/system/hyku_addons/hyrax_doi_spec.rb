require 'rails_helper'

RSpec.describe "HyraxDOI", js: true do
  let(:user) { create(:user) }
  let!(:account) { create(:account) }
  let(:attributes) do
    {
      doi_status_when_public: nil,
      visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
      user: user
    }
  end
  let!(:work) { create(:work, attributes) }
  let(:work_type) { work.class.name.underscore }

  before do
    driven_by(:rack_test)
    login_as(user, scope: :user)

    Site.update(account: account)
    allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
      block.call
    end
    host! "http://#{account.cname}"
  end

  describe "when the user edits a work without a minted DOI" do
    before do
      visit "/concern/#{work_type.to_s.pluralize}/#{work.id}/edit"
    end

    it "Sets up the page correctly" do
      expect(page).to have_content "Edit Work"

      find("a[role=tab]", text: "DOI").click

      # have_field with nil value isn't working properly here
      expect(page.find_field("DOI").value).to be_nil
      expect(page.find(:radio_button, "generic_work[doi_status_when_public]", checked: true).value).to eq ""
      # expect(page).to have_field("DOI status when work is public", "")

      find("a[role=tab]", text: "Description").click
      expect(page).to have_field("Title", with: work.title.first)
    end
  end
end
