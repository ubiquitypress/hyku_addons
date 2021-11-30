# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Minting a DOI for an existing work", multitenant: true, js: true do
  let(:user) { create(:user) }
  let(:attributes) do
    {
      title: ["Work title"],
      doi_status_when_public: nil,
      visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
      user: user,
      creator: [
        [{
          creator_name_type: "Personal",
          creator_given_name: "Johnny",
          creator_family_name: "Testison"
        }].to_json
      ],
      institution: ["University of Virginia"],
      resource_type: ["Blog post"]
    }
  end
  let(:work) { create(:work, attributes) }
  let(:work_type) { work.class.name.underscore }

  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:account) { create(:account, cname: "123456789") }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:doi_minting).and_return(true)

    Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id)
    Site.create(account: account)

    login_as user
  end

  describe "when the user edits a work without a minted DOI" do
    let(:attributes) do
      {
        title: ["Work title"],
        doi_status_when_public: nil,
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        user: user,
        creator: [
          [{
            creator_name_type: "Personal",
            creator_given_name: "Johnny",
            creator_family_name: "Testison"
          }].to_json
        ],
        institution: ["University of Virginia"],
        resource_type: ["Blog post"]
      }
    end

    before do
      visit "/concern/#{work_type.to_s.pluralize}/#{work.id}/edit"
    end

    it "Sets up the page correctly" do
      expect(page).to have_content "Edit Work"

      find("a[role=tab]", text: "DOI").click

      expect(find_field("DOI").value).to be_empty
      expect(find(:radio_button, "generic_work[doi_status_when_public]", checked: true).value).to be_empty
      expect(find(:radio_button, "generic_work[visibility]", checked: true).value).to eq "open"

      find("a[role=tab]", text: "Description").click
      expect(page).to have_field("Title", with: work.title.first)
    end

    context "when the user selects `findable`" do
      let(:new_title) { "New work title" }

      it "redirects the user to the works page" do
        fill_in_form(new_title)

        expect(page).to have_selector("h1", text: "Work", wait: 10)
        expect(page).to have_selector("h2", text: new_title)
      end

      it "enqueues a job to mint the DOI" do
        expect { fill_in_form(new_title) }.to have_enqueued_job(Hyrax::DOI::RegisterDOIJob).with(work.reload, registrar: "datacite", registrar_opts: {})
      end
    end
  end

  describe "when a user views a work with a minted DOI" do
    let(:attributes) do
      {
        title: ["Work title"],
        doi: [doi],
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        user: user,
        creator: [
          [{
            creator_name_type: "Personal",
            creator_given_name: "Johnny",
            creator_family_name: "Testison"
          }].to_json
        ],
        institution: ["University of Virginia"],
        resource_type: ["Blog post"]
      }
    end

    let(:doi) { "10.18130/v3-k4an-w022" }

    it "has a link to the DOI" do
      visit "/concern/#{work_type.to_s.pluralize}/#{work.id}"

      expect(page).to have_selector("a", text: "https://doi.org/#{doi}")
    end
  end

  private

    def fill_in_form(title)
      choose "Findable"
      choose "generic_work_visibility_open"
      check "agreement"

      find("a[role=tab]", text: "Description").click
      fill_in("Title", with: title)
      find("input[type=submit]").click
    end
end
