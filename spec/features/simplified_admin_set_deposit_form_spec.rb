# frozen_string_literal: true

require 'rails_helper'

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature "Simplfied AdminSet deposit form", js: true do
  let(:user) { create(:user) }
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) do
    Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template)
  end
  let(:work_type) { "book" }
  let(:human_work_type_name) { I18n.t("hyrax.select_type.#{work_type}.name") }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)

    # Create a single action that can be taken
    Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
  end

  context "when the user is depositing" do
    before do
      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      login_as user
    end

    scenario "it doesn't show the relationships tab", js: true do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      choose "payload_concern", option: work_type.to_s.camelize
      click_button "Create work"

      expect(page).not_to have_selector("a[aria-controls='relationships']")
    end
  end

  context "when the user is managing" do
    let(:work) { create(:work, title: ["Moomin"], depositor: user.user_key) }
    let(:admin_user) { create(:admin) }
    let(:main_app) { Rails.application.routes.url_helpers }

    before do
      login_as admin_user
    end

    scenario "it shows the relationships tab", js: true do
      visit main_app.edit_hyrax_generic_work_path(work)

      expect(page).to have_selector("a[aria-controls='relationships']")
    end
  end
end
