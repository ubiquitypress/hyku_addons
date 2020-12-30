RSpec.shared_context 'create work user context' do
  let(:user_attributes) do
    { email: 'test@example.com' }
  end
  let(:user) do
    User.new(user_attributes) { |u| u.save(validate: false) }
  end
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

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

  def add_new_work(work_type)
    human_work_type_name = I18n.t("hyrax.select_type.#{work_type}.name")
    visit '/dashboard?locale=en'
    click_link "Works"
    click_link "Add new work"

    choose "payload_concern", option: human_work_type_name
    click_button "Create work"

    expect(page).to have_content "Add New #{human_work_type_name}"
    yield if block_given?
  end

  def add_files_to_work
    click_link "Files" # switch tab
    expect(page).to have_content "Add files"
    expect(page).to have_content "Add folder"
    within('span#addfiles') do
      attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/image.jp2", visible: false)
      attach_file("files[]", "#{Hyrax::Engine.root}/spec/fixtures/jp2_fits.xml", visible: false)
    end

  end
end