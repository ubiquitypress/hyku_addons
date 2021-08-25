# frozen_string_literal: true

require "rails_helper"

include Warden::Test::Helpers

RSpec.feature "Simplfied AdminSet deposit form", js: true do
  let(:user) { create(:user) }
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) do
    options = {
      active: true,
      name: "test-workflow",
      permission_template: permission_template,
      allows_access_grant: true
    }
    Sipity::Workflow.create!(options)
  end
  let(:work_type) { "book" }
  let(:human_work_type_name) { I18n.t("hyrax.select_type.#{work_type}.name") }
  let(:routes) { Rails.application.routes.url_helpers }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:simplified_admin_set_selection).and_return(true)

    # Create a single action that can be taken
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)
  end

  context "when the user is depositing" do
    before do
      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: "user",
        agent_id: user.user_key,
        access: "deposit"
      )
      login_as user
    end

    scenario "it doesn't show the relationships tab", js: true do
      visit "/dashboard"
      click_link "Works"
      click_link "Add new work"

      choose "payload_concern", option: work_type.to_s.camelize
      click_button "Create work"

      expect(page).not_to have_selector("a[aria-controls='relationships']")
    end
  end

  context "when the user is an admin" do
    let(:work) { create(:work, title: ["Moomin"], depositor: user.user_key) }
    let(:admin_user) { create(:admin) }

    before do
      login_as admin_user
    end

    scenario "it shows the relationships tab", js: true do
      visit routes.edit_hyrax_generic_work_path(work)

      expect(page).to have_selector("a[aria-controls='relationships']")
    end
  end

  context "when the user is a manager" do
    # NOTE: In order to get the workflow working without properly understanding the Sipity
    # permissioned i'm hacking it and adding the manager to `edit_users` to mimic the process.
    # This isn't what i want and i'd love to know how to do it properly.
    let(:work) do
      params = {
        title: ["Moomin"],
        depositor: depositor.user_key,
        admin_set: admin_set,
        edit_users: [manager.user_key]
      }
      create(:work, params)
    end
    let(:manager) { create(:user) }
    let(:depositor) { create(:user) }
    let(:admin_set) { FactoryBot.create(:admin_set, title: ["Private Admin Set"]) }
    let(:permission_template) do
      options = {
        source_id: admin_set.id,
        visibility: "restricted",
        release_period: "now"
      }
      Hyrax::PermissionTemplate.find_or_create_by!(options)
    end

    before do
      login_as manager
    end

    it "shows the relationship tab" do
      visit routes.edit_hyrax_generic_work_path(work)

      expect(page).to have_selector("a[aria-controls='relationships']")
    end
  end
end
