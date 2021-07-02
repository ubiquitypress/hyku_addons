# frozen_string_literal: true
require 'rails_helper'
require File.expand_path('../helpers/create_work_user_context', __dir__)

include Warden::Test::Helpers

RSpec.describe 'autofilling the form from DOI', js: true do
  include_context 'create work user context' do
    let(:work_type) { "article" }

    # FIXME: Stub web requests
    before do
      WebMock.disable!
    end

    after do
      WebMock.enable!
    end

    scenario do
      optional "Test JS failing to set fields but works in UI" if ENV["CI"]

      visit_new_work_page
      fill_in "#{work_type}_doi", with: '10.5438/4k3m-nyvg'
      accept_confirm do
        click_link "doi-autofill-btn"
      end

      click_on 'Descriptions'
      click_on 'Additional fields'

      # expect form fields have been filled in
      expect(page).to have_content("The following fields were auto-populated", wait: 30)
      expect(page).to have_field("#{work_type}_title", with: 'Eating your own Dog Food', wait: 30)
      expect(page).to have_field("#{work_type}_creator__creator_family_name", with: 'Fenner', wait: 30)
      expect(page).to have_field("#{work_type}_creator__creator_given_name", with: 'Martin', wait: 30)
      expect(page).to have_field("#{work_type}_abstract", with: 'Eating your own dog food is a slang term to describe that an organization '\
                                                                'should itself use the products and services it provides. For DataCite this '\
                                                                'means that we should use DOIs with appropriate metadata and strategies for '\
                                                                'long-term preservation for...', wait: 30)
      expect(page).to have_field("#{work_type}_keyword", with: 'datacite', wait: 30)
      expect(page).to have_field("#{work_type}_keyword", with: 'doi', wait: 30)
      expect(page).to have_field("#{work_type}_keyword", with: 'metadata', wait: 30)
      expect(page).to have_field("#{work_type}_publisher", with: 'DataCite', wait: 30)

      # We don't use these fields
      # expect(page).to have_field("#{work_type}_date_created", with: '2016', wait: 30)
      # expect(page).to have_field("#{work_type}_identifier", with: 'MS-49-3632-5083', wait: 30)

      # expect page to have forwarded to metadata tab
      # expect(URI.parse(page.current_url).fragment).to eq 'metadata'
    end
  end
end
