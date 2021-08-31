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
    let(:funder_response) do
      {
        "status": "ok",
        "message-type": "funder-list",
        "message-version": "1.0.0",
        "message": {
          "items-per-page": 20,
          "query": {
            "start-index": 0,
            "search-terms": "Japan Foundation London"
          },
          "total-results": 1,
          "items": [
            {
              "id": "100008699",
              "location": "United Kingdom",
              "name": "Japan Foundation, London",
              "alt-names": ["Japan Foundation London"],
              "uri": "http:\/\/dx.doi.org\/10.13039\/100008699",
              "replaces": [],
              "replaced-by": [],
              "tokens": ["japan", "foundation", "london", "japan", "foundation", "london"]
            }
          ]
        }
      }
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

      # Stub Crossref funder request
      stub_request(:get, "http://api.crossref.org/funders?query=Japan%20Foundation%20London").to_return(status: 200, body: funder_response.to_json)

      login_as user
    end
    it 'persists a new work with only required fields' do
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
      end
      click_link "Descriptions" # switch tab

      # Title
      fill_in('Title', with: 'My Test Work')

      # Creator
      select('Personal', from: 'generic_work_creator__creator_name_type')
      fill_in('generic_work_creator__creator_family_name', with: 'Hawking')
      fill_in('generic_work_creator__creator_given_name', with: 'Stephen')
      fill_in('generic_work_creator__creator_orcid', with: '0000-0002-9079-593X')
      select('Staff member', from: 'generic_work_creator__creator_institutional_relationship')
      fill_in('generic_work_creator__creator_isni', with: '0000 0001 2103 4996')

      # Resource type
      select('Blog post', from: 'Resource type')

      # Institution
      select('University of Virginia', from: 'Institution')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('generic_work_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')

      # Save
      page.find('input[name=save_with_files]').click

      ################
      # Check metadata fields render properly after save
      # Title
      expect(page).to have_content('My Test Work')

      # Visibility
      expect(page).to have_content('Public')

      # Creator
      expect(page).to have_content('Hawking, Stephen')
      expect(page).to have_link('', href: 'https://orcid.org/000000029079593X')
      expect(page).to have_link('', href: 'https://isni.org/isni/0000000121034996')

      # Resource type
      expect(page).to have_link('Blog post', href: /catalog\?f.*Bresource_type_sim.*Blog\+post/)

      # Institution
      expect(page).to have_content('University of Virginia')

      expect(page).not_to have_content('Contributor') # FIXME
      expect(page).not_to have_content('Editor') # FIXME
      expect(page).not_to have_content('Funder')
      expect(page).not_to have_content('Current HE Institution')
      expect(page).not_to have_content('Alternate identifier')
      expect(page).not_to have_content('Related identifier')

      expect(page).to have_content "Your files are being processed by Hyku in the background."
    end

    it 'persists a new work with multi-part fields' do
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
      select('Staff member', from: 'generic_work_creator__creator_institutional_relationship')
      fill_in('generic_work_creator__creator_isni', with: '0000 0001 2103 4996')

      # Resource type
      select('Blog post', from: 'Resource type')

      # Alternative title
      fill_in('Alt title', with: 'All fields test')

      # Contributor
      select('Personal', from: 'generic_work_contributor__contributor_name_type')
      fill_in('generic_work_contributor__contributor_family_name', with: 'Jones')
      fill_in('generic_work_contributor__contributor_given_name', with: 'James Earl')
      fill_in('generic_work_contributor__contributor_isni', with: '0000 0001 2030 4456')
      select('Narrator', from: 'generic_work_contributor__contributor_type')

      # Abstract
      fill_in('Abstract', with: 'Testing all fields persist and render')

      # Date published
      select('2021', from: 'generic_work_date_published__date_published_year')
      select('01', from: 'generic_work_date_published__date_published_month')
      select('01', from: 'generic_work_date_published__date_published_day')

      # Media
      fill_in('Media', with: "video")

      # Duration
      fill_in('Duration', with: '6 minutes')

      # Institution
      select('University of Virginia', from: 'Institution')

      # Organizational unit
      fill_in('Organisational Unit', with: 'Repositories team')

      # Project name
      fill_in('Project name', with: 'Project Hydra')

      # Funder
      # TODO: Test autocomplete
      fill_in('generic_work_funder__funder_name', with: 'Japan Foundation, London')
      fill_in('generic_work_funder__funder_doi', with: 'http://dx.doi.org/10.13039/100008699')
      fill_in('generic_work_funder__funder_isni', with: '0000 0004 0516 7766')
      fill_in('generic_work_funder__funder_ror', with: 'https://ror.org/024jbvq59')
      fill_in('generic_work_funder__funder_award_', with: 'ABC-12345')

      # Event title

      # Event location

      # Event date
      select('2020', from: 'generic_work_event_date__event_date_year')
      select('12', from: 'generic_work_event_date__event_date_month')
      select('25', from: 'generic_work_event_date__event_date_day')

      # Series name

      # Book title

      # Editor
      select('Personal', from: 'generic_work_editor__editor_name_type')
      fill_in('generic_work_editor__editor_isni', with: '0000 0001 2103 5000')
      fill_in('generic_work_editor__editor_orcid', with: '0000-0002-9079-600X')
      fill_in('generic_work_editor__editor_family_name', with: 'Curry')
      fill_in('generic_work_editor__editor_given_name', with: 'Timothy')
      select('Staff member', from: 'generic_work_editor__editor_institutional_relationship')

      # Journal title
      # Alternative journal title
      # Volume
      # Edition
      # Version number
      # Issue
      # Pagination
      # Article number
      # Publisher
      # Place of publication
      # ISBN
      # ISSN
      # eISSN

      # Current HE institution
      # TODO test autocomplete
      select('Abertay University', from: 'generic_work_current_he_institution__current_he_institution_name')

      # Date accepted
      select('2020', from: 'generic_work_date_accepted__date_accepted_year')
      select('12', from: 'generic_work_date_accepted__date_accepted_month')
      select('31', from: 'generic_work_date_accepted__date_accepted_day')

      # Date submitted
      select('2020', from: 'generic_work_date_submitted__date_submitted_year')
      select('12', from: 'generic_work_date_submitted__date_submitted_month')
      select('30', from: 'generic_work_date_submitted__date_submitted_day')

      # Official URL
      # Related URL
      # Related exhibition
      # Related exhibition venue

      # Related exhibition date
      select('2021', from: 'generic_work_related_exhibition_date__related_exhibition_date_year')
      select('01', from: 'generic_work_related_exhibition_date__related_exhibition_date_month')
      select('04', from: 'generic_work_related_exhibition_date__related_exhibition_date_day')

      # Language
      # License
      select('CC BY 4.0 Attribution', from: 'generic_work_license')
      # TODO?

      # Rights statement
      # TODO?

      # Rights holder
      # DOI

      # Qualification name
      select('PhD', from: 'generic_work_qualification_name')

      # Qualification level
      select('Doctoral', from: 'generic_work_qualification_level')

      # Alternate identifier
      fill_in('generic_work_alternate_identifier__alternate_identifier', with: 'CD12345')
      fill_in('generic_work_alternate_identifier__alternate_identifier_type', with: 'Local CD IDs')

      # Related identifier
      fill_in('generic_work_related_identifier__related_identifier', with: '978-3-16-148410-0')
      select('ISBN', from: 'generic_work_related_identifier__related_identifier_type')
      select('Cites', from: 'generic_work_related_identifier__relation_type')

      # Peer-reviewed (Refereed)
      select('Peer-reviewed', from: 'generic_work_refereed')

      # Keywords
      fill_in('Keyword', with: 'keyword_testing')

      # Dewey
      # Library of Congress Classification
      # Additional information
      # Rendering ids

      # Visibility
      select('In Copyright', from: 'Rights statement')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('generic_work_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')

      # Save
      page.find('input[name=save_with_files]').click

      ################
      # Check metadata fields render properly after save
      # Title
      expect(page).to have_content('My Test Work')

      # Visibility
      expect(page).to have_content('Public')

      # Creator
      expect(page).to have_content('Hawking, Stephen')
      expect(page).to have_link('', href: 'https://orcid.org/000000029079593X')
      expect(page).to have_link('', href: 'https://isni.org/isni/0000000121034996')

      # Resource type
      expect(page).to have_link('Blog post', href: /catalog\?f.*Bresource_type_sim.*Blog\+post/)

      # Alternative title
      expect(page).to have_content('All fields test')

      # Contributor
      expect(page).to have_content('Jones, James Earl')
      expect(page).to have_link('', href: 'https://isni.org/isni/0000000120304456')

      # Abstract
      expect(page).to have_content('Testing all fields persist and render')

      # Date published
      expect(page).to have_content('2021-1-1')

      # Media
      expect(page).to have_content('video')

      # Duration
      expect(page).to have_content('6 minutes')

      # Institution
      expect(page).to have_content('University of Virginia')

      # Organizational unit
      expect(page).to have_content('Repositories team')

      # Project name
      expect(page).to have_content('Project Hydra')

      # Funder
      # TODO: Test autocomplete
      expect(page).to have_content('Japan Foundation, London')
      expect(page).to have_content('http://dx.doi.org/10.13039/100008699')
      expect(page).to have_content('0000 0004 0516 7766')
      expect(page).to have_content('https://ror.org/024jbvq59')
      expect(page).to have_content('ABC-12345')

      # Event title

      # Event location

      # Event date
      expect(page).to have_content('2020-12-25')

      # Series name

      # Book title

      # Editor
      expect(page).to have_link('', href: 'https://isni.org/isni/0000000121035000')
      expect(page).to have_link('', href: 'https://orcid.org/000000029079600X')
      expect(page).to have_content('Curry, Timothy')

      # Journal title
      # Alternative journal title
      # Volume
      # Edition
      # Version number
      # Issue
      # Pagination
      # Article number
      # Publisher
      # Place of publication
      # ISBN
      # ISSN
      # eISSN

      # Current HE institution
      expect(page).to have_content('Abertay University')
      # expect(page).to have_content('0000 0001 0339 8665')
      # expect(page).to have_content('https://ror.org/04mwwnx67')

      # Date accepted
      expect(page).to have_content('2020-12-30')

      # Date submitted
      expect(page).to have_content('2020-12-31')

      # Official URL
      # Related URL
      # Related exhibition
      # Related exhibition venue

      # Related exhibition date
      expect(page).to have_content('2021-1-4')

      # Language
      # License
      expect(page).to have_link('CC BY 4.0 Attribution', href: 'https://creativecommons.org/licenses/by/4.0/')
      # TODO?

      # Rights statement
      # TODO?

      # Rights holder
      # DOI

      # Qualification name
      expect(page).to have_content('PhD')

      # Qualification level
      expect(page).to have_content('Doctoral')

      # Alternate identifier
      expect(page).to have_content('CD12345')
      expect(page).to have_content('Local CD IDs')

      # Peer-reviewed
      # This isn't rendered on the show page currently

      # Keywords
      expect(page).to have_content('keyword_testing')

      # Dewey
      # Library of Congress Classification
      # Additional information
      # Rendering ids

      # Related identifier
      expect(page).to have_content('978-3-16-148410-0')
      expect(page).to have_content('ISBN')
      expect(page).to have_content('Cites')

      expect(page).to have_content "Your files are being processed by Hyku in the background."
    end
  end
end
