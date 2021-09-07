# frozen_string_literal: true
require 'rails_helper'
require File.expand_path('../helpers/create_redlands_work_user_context', __dir__)

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a RedlandsChaptersAndBookSection', js: false do
  include_context 'create redlands work user context' do
    let(:work_type) { "redlands_chapters_and_book_section" }

    def add_metadata_to_work
      click_link "Descriptions" # switch tab
      fill_in("#{work_type}_title", with: 'My Test Work')
      fill_in('Keyword', with: 'testing')
      select('Organisational', from: "#{work_type}_creator__creator_name_type")
      fill_in("#{work_type}_creator__creator_organization_name", with: 'Ubiquity Press')
      expect(page).not_to have_selector("#redlands_chapters_and_book_section_version_number[required=true]")
      yield if block_given?
    end

    scenario do
      visit_new_work_page
      add_files_to_work
      add_metadata_to_work
      apply_work_visibility
      check_agreement_and_submit
    end
  end
end
