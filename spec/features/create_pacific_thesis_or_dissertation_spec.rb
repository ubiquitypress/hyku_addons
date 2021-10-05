# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a PacificThesisOrDissertation', js: false do
  let(:user) { User.new(email: 'test@example.com') { |u| u.save(validate: false) } }
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }
  let(:work_type) { "pacific_thesis_or_dissertation" }
  let(:new_work_path) { "concern/#{work_type.to_s.pluralize}/new" }

  before do
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
  end

  it 'renders the new Pacific Work page' do
    visit new_work_path

    expect(page).to have_content "Add New Pacific Thesis Or Dissertation"
  end

  it 'adds files to work' do
    visit new_work_path
    click_link "Files"
    expect(page).to have_content "Add files"
    expect(page).to have_content "Add folder"
    within('span#addfiles') do
      attach_file("files[]", Rails.root.join('spec', 'fixtures', 'hyrax', 'image.jp2'), visible: false)
      attach_file("files[]", Rails.root.join('spec', 'fixtures', 'hyrax', 'jp2_fits.xml'), visible: false)
    end
  end

  it 'applys work visibility' do
    visit new_work_path
    visibility = :open
    find('body').click
    choose("#{work_type}_visibility_#{visibility}")

    expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
  end

  it 'saves the work' do
    visit new_work_path
    click_link "Descriptions"
    fill_in("#{work_type}_title", with: 'My Test Work')
    select('Organisational', from: "#{work_type}_creator__creator_name_type")
    fill_in("#{work_type}_creator__creator_organization_name", with: 'Ubiquity Press')
    check('agreement')
    click_on('Save')
    expect(page).to have_content('My Test Work')
    expect(page).to have_content('Public')
    expect(page).to have_content("Your files are being processed by Hyku in the background.")
  end

  context "when rendering the form" do
    before do
      visit new_work_path
      click_on "Additional fields"
    end

    it "renders all simple worktype fields" do
      worktype_simple_fields = %w[title alt_title resource_type abstract
                                  pagination is_included_in publisher additional_links
                                  rights_holder license degree org_unit official_link subject keyword add_info]
      worktype_simple_fields.each do |field|
        expect(page).to have_field("#{work_type}_#{field}")
      end
    end

    it "renders complex name fields" do
      worktype_complex_name_fields = %w[creator contributor]
      worktype_complex_name_fields.each do |field|
        expect(page).to have_field("#{work_type}_#{field}__#{field}_family_name")
        expect(page).to have_field("#{work_type}_#{field}__#{field}_given_name")
      end
    end

    it "renders all date fields" do
      worktype_date_fields = %w[date_published]
      worktype_date_fields.each do |field|
        expect(page).to have_field("#{work_type}_#{field}__#{field}_year")
        expect(page).to have_field("#{work_type}_#{field}__#{field}_month")
        expect(page).to have_field("#{work_type}_#{field}__#{field}_day")
      end
    end
  end
end
