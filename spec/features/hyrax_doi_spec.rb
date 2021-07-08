# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Minting a DOI for an existing work", js: true, clean: true do
  let(:user) { create(:user) }
  let!(:account) { create(:account) }
  let(:attributes) do
    {
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
  let!(:work) { create(:work, attributes) }
  let(:work_type) { work.class.name.underscore }

  let!(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let!(:workflow) do
    Sipity::Workflow.create!(
      active: true,
      name: 'test-workflow',
      permission_template: permission_template
    )
  end

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:doi_minting).and_return(true)

    # Create a single action that can be taken
    Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

    # Grant the user access to deposit into the admin set.
    Hyrax::PermissionTemplateAccess.create!(
      permission_template_id: permission_template.id,
      agent_type: 'user',
      agent_id: user.user_key,
      access: 'deposit'
    )

    login_as user

    WebMock.disable!
  end

  after do
    WebMock.enable!
  end

  describe "when the user edits a work without a minted DOI" do
    before do
      visit "/concern/#{work_type.to_s.pluralize}/#{work.id}/edit"
    end

    it "Sets up the page correctly" do
      expect(page).to have_content "Edit Work"

      find("a[role=tab]", text: "DOI").click

      # have_field with nil value isn't working properly here
      expect(find_field("DOI").value).to eq ""
      expect(find(:radio_button, "generic_work[doi_status_when_public]", checked: true).value).to eq ""
      expect(find(:radio_button, "generic_work[visibility]", checked: true).value).to eq "open"

      find("a[role=tab]", text: "Description").click
      expect(page).to have_field("Title", with: work.title.first)
    end

    context "when the user selects `findable`" do
      it "mints a DOI" do
        choose "Findable"
        choose "generic_work_visibility_open"
        check "agreement"

        find("input[type=submit]").click

        # expect(page).to have_current_path(polymorphic_path(work))
        expect(page).to have_selector("h1", text: "Work", wait: 10)
        expect(page).to have_selector("h2", text: work.title.first)
      end
    end
  end
end
