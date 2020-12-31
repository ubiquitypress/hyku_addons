# Generated via
#  `rails generate hyrax:work BookContribution`
require 'rails_helper'
require File.expand_path('../helpers/create_work_user_context', __dir__)

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a BookContribution', js: false do
  include_context 'create work user context' do
    let(:work_type) { "book_contribution" }

    scenario do
      visit_new_work_page
      add_files_to_work
      add_metadata_to_work do
        # fill_in('Creator', with: 'Doe, Jane')
      end
      set_visibility_to_work
      check_agreement_and_submit
    end
  end
end
