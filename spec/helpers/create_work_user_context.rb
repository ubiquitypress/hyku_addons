# frozen_string_literal: true
RSpec.shared_context 'create work user context' do
  let(:user_attributes) do
    { email: 'test@example.com' }
  end
  let(:user) do
    User.new(user_attributes) { |u| u.save(validate: false) }
  end
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) do
    Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template)
  end
  let(:work_type) { "generic_work" }

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

  scenario "Create popup", js: true do
    visit '/dashboard'
    click_link "Works"
    click_link "Add new work"
    choose "payload_concern", option: work_type.to_s.camelize
    click_button "Create work"
    expect(page).to have_content "Add New #{human_work_type_name}"
  end

  def visit_new_work_page
    visit "concern/#{work_type.to_s.pluralize}/new"
    expect(page).to have_content "Add New #{human_work_type_name}"
  end

  def add_files_to_work
    click_link "Files" # switch tab
    expect(page).to have_content "Add files"
    expect(page).to have_content "Add folder"
    within('span#addfiles') do
      attach_file("files[]", Rails.root.join('spec', 'fixtures', 'hyrax', 'image.jp2'), visible: false)
      attach_file("files[]", Rails.root.join('spec', 'fixtures', 'hyrax', 'jp2_fits.xml'), visible: false)
    end
  end

  def add_metadata_to_work
    click_link "Descriptions" # switch tab
    fill_in("#{work_type}_title", with: 'My Test Work')
    fill_in('Keyword', with: 'testing')
    select('In Copyright', from: 'Rights statement')
    select('Organisational', from: "#{work_type}_creator__creator_name_type")
    fill_in("#{work_type}_creator__creator_organization_name", with: 'Ubiquity Press')
    select("British Library", from: "#{work_type}_institution")
    yield if block_given?
  end

  def apply_work_visibility(visibility = :open)
    find('body').click
    choose("#{work_type}_visibility_#{visibility}")
    case visibility
    when :open
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
    end
  end

  def check_agreement_and_submit
    check('agreement')
    click_on('Save')
    expect(page).to have_content('My Test Work')
    expect(page).to have_content('Public')
    expect(page).to have_content("Your files are being processed by Hyku in the background.")
  end

  def human_work_type_name
    I18n.t("hyrax.select_type.#{work_type}.name")
  end
end
