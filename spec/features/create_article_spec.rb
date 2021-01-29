# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Article`
require 'rails_helper'
require File.expand_path('../helpers/create_work_user_context', __dir__)

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create an Article', js: false do
  include_context 'create work user context' do
    let(:work_type) { "article" }

    scenario do
      visit_new_work_page
      add_files_to_work
      add_metadata_to_work do
        # fill_in('Creator', with: 'Doe, Jane')
      end
      apply_work_visibility
      check_agreement_and_submit
    end
  end
end
