# frozen_string_literal: true

# require File.expand_path('../helpers/create_ubiquity_template_user_context', __dir__)
require "rails_helper"
require HykuAddons::Engine.root.join("spec", "helpers", "fill_in_fields.rb").to_s

include Warden::Test::Helpers

RSpec.feature "Create a UbiquityTemplateWork", js: true do
  let(:work_type) { "ubiquity_template_work" }

  let(:user) { User.new(email: "test@example.com") { |u| u.save(validate: false) } }
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) { Sipity::Workflow.create!(active: true, name: "test-workflow", permission_template: permission_template) }
  let(:new_work_path) { "concern/#{work_type.to_s.pluralize}/new" }
  let(:permission_options) do
    { permission_template_id: permission_template.id, agent_type: "user", agent_id: user.user_key, access: "deposit" }
  end

  let(:title) { "Ubiquity Template Work Item" }
  let(:alt_title) { ["Alt Title 1", "Alt Title 2"] }
  let(:creator_given_name) { "Johnny" }
  let(:creator_family_name) { "Smithy" }
  let(:creator) do
    {
      creator_name_type: "Personal",
      creator_family_name: creator_family_name,
      creator_given_name: creator_given_name
    }
  end
  let(:contributor_given_name1) { "Johnny" }
  let(:contributor_family_name1) { "Smithy" }
  let(:contributor_organization_name) { "A Test Company Name" }
  let(:contributor) do
    [
      { contributor_name_type: "Personal", contributor_family_name: contributor_family_name1, contributor_given_name: contributor_given_name1 },
      { contributor_name_type: "Organisational", contributor_given_name: contributor_organization_name }
    ]
  end

  let(:resource_type) { "Other" }
  let(:date_published) { { year: "2020", month: "02", day: "02" } }
  let(:date_submitted) { { year: "2019", month: "03", day: "03" } }
  let(:date_accepted) { { year: "2018", month: "04", day: "04" } }
  let(:source) { ["source 1", "Source 2"] }

  before do
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)
    Hyrax::PermissionTemplateAccess.create!(permission_options)

    login_as user
    visit new_work_path
  end

  it "renders the new work page" do
    page.save_screenshot
    expect(page).to have_content "Add New Ubiquity Template Work"
  end

  context "when the form is filled out" do
    before do
      click_link "Descriptions"
      click_on "Additional fields"

      fill_in_title(title)
      fill_in_alt_title(alt_title)
      fill_in_resource_type(resource_type)
      fill_in_creator(creator)
      fill_in_date_published(date_published)
      fill_in_date_submitted(date_submitted)
      fill_in_date_accepted(date_accepted)
      fill_in_contributor(contributor)


      fill_in_source(source)
    end

    describe "date_published" do
      let(:field) { "date_published" }

      it "contains the date_published fields" do
        page.save_screenshot
      end

      context "" do

      end
    end
  end
end

