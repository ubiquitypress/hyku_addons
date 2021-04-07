# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work UvaWork`
require 'rails_helper'
require File.expand_path('../helpers/create_uva_work_user_context', __dir__)

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a UvaWork', js: false do
  include_context 'create uva work user context' do
    let(:work_type) { "uva_work" }

    scenario do
      visit_new_work_page
      add_files_to_work
      add_metadata_to_work
      apply_work_visibility
      check_agreement_and_submit
    end
  end
end
