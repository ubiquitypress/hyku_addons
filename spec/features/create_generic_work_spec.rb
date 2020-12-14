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
              "tokens": ["japan","foundation","london","japan","foundation","london"]
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
      # TODO authoritity service
      fill_in('Institution', with: 'Advancing Hyku')

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
      # TODO

      # Series name

      # Book title

      # Editor
      # TODO

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
      # TODO

      # Date accepted
      # TODO

      # Date submitted
      # TODO

      # Official URL
      # Related URL
      # Related exhibition
      # Related exhibition venue

      # Related exhibition date
      # TODO

      # Language
      # License
      # TODO?

      # Rights statement
      # TODO?

      # Rights holder
      # DOI

      # Qualification name
      # TODO
      
      # Qualification level
      # TODO

      # Alternative identifier
      # TODO

      # Related identifier
      # TODO

      # Peer-reviewed
      # TODO

      # Keywords
      fill_in('Keyword', with: 'keyword_testing')

      # Dewey
      # Library of Congress Classification
      # Additional information
      # Rendering ids
      
      
      # Related identifier
      fill_in('generic_work_related_identifier__related_identifier', with: '978-3-16-148410-0')
      select('ISBN', from: 'generic_work_related_identifier__related_identifier_type')
      select('Cites', from: 'generic_work_related_identifier__relation_type')

      # Visibility
      select('In Copyright', from: 'Rights statement')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('generic_work_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      # rubocop:enable Metrics/LineLength
      check('agreement')

      # Save
      page.find('input[name=save_with_files]').click

      ################
      # Check metadata fields render properly after save
      # Title
      expect(page).to have_content('My Test Work')

      # Creator
      expect(page).to have_content('Hawking, Stephen')
      expect(page).to have_link('', href: 'https://orcid.org/000000029079593X')
      expect(page).to have_link('', href: 'https://isni.org/isni/0000000121034996')

      # Resource type
      expect(page).to have_link('Article', href: /catalog\?f.*Bresource_type_sim.*Article/)

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
      expect(page).to have_content('Advancing Hyku')

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
      # TODO

      # Series name

      # Book title

      # Editor
      # TODO

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
      # TODO

      # Date accepted
      # TODO

      # Date submitted
      # TODO

      # Official URL
      # Related URL
      # Related exhibition
      # Related exhibition venue

      # Related exhibition date
      # TODO

      # Language
      # License
      # TODO?

      # Rights statement
      # TODO?

      # Rights holder
      # DOI

      # Qualification name
      # TODO
      
      # Qualification level
      # TODO

      # Alternative identifier
      # TODO

      # Related identifier
      # TODO

      # Peer-reviewed
      # TODO

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
    # rubocop:enable RSpec/ExampleLength
  end
end
