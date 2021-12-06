# frozen_string_literal: true
require "rails_helper"

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature "Select work type deposit form", js: true do
  let(:user_attributes) do
    { email: "test@example.com" }
  end
  let(:user) do
    User.new(user_attributes) { |u| u.save(validate: false) }
  end
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) do
    Sipity::Workflow.create!(active: true, name: "test-workflow", permission_template: permission_template)
  end
  let(:work_type) { "book" }
  let(:human_work_type_name) { I18n.t("hyrax.select_type.#{work_type}.name") }

  before do
    # Create a single action that can be taken
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)

    # Grant the user access to deposit into the admin set.
    Hyrax::PermissionTemplateAccess.create!(
      permission_template_id: permission_template.id,
      agent_type: "user",
      agent_id: user.user_key,
      access: "deposit"
    )
    login_as user
  end

  scenario "Create popup", js: true do
    visit "/dashboard"
    click_link "Works"
    click_link "Add new work"
    choose "payload_concern", option: work_type.to_s.camelize
    click_button "Create work"
    expect(page).to have_content "Add New #{human_work_type_name}"
  end
end
