# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work GenericWork`
require 'rails_helper'

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.describe 'Create a GenericWork', js: true, clean: true do
  include Warden::Test::Helpers
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let!(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let!(:workflow) do
      Sipity::Workflow.create!(
        active: true,
        name: 'test-workflow',
        permission_template:
        permission_template
      )
    end

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

    # rubocop:disable RSpec/ExampleLength
    it do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      choose "payload_concern", option: "GenericWork"
      click_button "Create work"

      # expect(page).to have_content "Add New Work"
      # click_link "Files" # switch tab
      page.find('a[href="#files"]').click
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"
      within('span#addfiles') do
        attach_file("files[]", File.join(fixture_path, 'hyrax', 'image.jp2'), visible: false)
        attach_file("files[]", File.join(fixture_path, 'hyrax', 'jp2_fits.xml'), visible: false)
      end
      click_link "Descriptions" # switch tab
      click_link "Additional fields" # expand form for additional fields
      fill_in('Title', with: 'My Test Work')

      # Creator
      select('Personal', from: 'generic_work_creator__creator_name_type')
      fill_in('generic_work_creator__creator_family_name', with: 'Hawking')
      fill_in('generic_work_creator__creator_given_name', with: 'Stephen')
      fill_in('generic_work_creator__creator_orcid', with: '0000-0002-9079-593X')
      select('Staff member', from: 'generic_work_creator__creator_institutional_relationship_')
      fill_in('generic_work_creator__creator_isni', with: '0000 0001 2103 4996')

      # Resource type
      select('Article', from: 'Resource type')

      # Contributor
      select('Personal', from: 'generic_work_contributor__contributor_name_type')
      fill_in('generic_work_contributor__contributor_family_name', with: 'Jones')
      fill_in('generic_work_contributor__contributor_given_name', with: 'James Earl')
      fill_in('generic_work_contributor__contributor_isni', with: '0000 0001 2030 4456')
      select('Narrator', from: 'generic_work_contributor__contributor_type')

      fill_in('Keyword', with: 'testing')
      fill_in('Institution', with: 'Advancing Hyku')
      select('In Copyright', from: 'Rights statement')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('generic_work_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      # rubocop:enable Metrics/LineLength
      check('agreement')

      # click_on('Save')
      page.find('input[name=save_with_files]').click

      # Check metadata fields render properly after save
      # Title
      expect(page).to have_content('My Test Work')

      # Creator
      expect(page).to have_content('Hawking, Stephen')
      expect(page).to have_link('', href: 'https://orcid.org/000000029079593X')
      expect(page).to have_link('', href: 'https://isni.org/isni/0000000121034996')

      # Resource type
      expect(page).to have_link('Article', href: /catalog\?f.*Bresource_type_sim.*Article/)

      # Contributor
      expect(page).to have_content('Jones, James Earl')
      expect(page).to have_link('', href: 'https://isni.org/isni/0000000120304456')

      expect(page).to have_content('Advancing Hyku')
      expect(page).to have_content "Your files are being processed by Hyku in the background."
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
