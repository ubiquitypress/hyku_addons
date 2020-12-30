# Generated via
#  `rails generate hyrax:work BookContribution`
require 'rails_helper'
require File.expand_path('../helpers/create_work_user_context', __dir__)

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a BookContribution', js: false do
  include_context 'create work user context' do
    scenario do
      add_new_work(:book_contribution)
      add_files_to_work
      click_link "Descriptions" # switch tab
      fill_in('Title', with: 'My Test Work')
      fill_in('Creator', with: 'Doe, Jane')
      fill_in('Keyword', with: 'testing')
      select('In Copyright', from: 'Rights statement')

      # With selenium and the chrome driver, focus remains on the
      # select box. Click outside the box so the next line can't find
      # its element
      find('body').click
      choose('book_contribution_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      check('agreement')

      click_on('Save')
      expect(page).to have_content('My Test Work')
      expect(page).to have_content "Your files are being processed by Hyrax in the background."
    end
  end
end
