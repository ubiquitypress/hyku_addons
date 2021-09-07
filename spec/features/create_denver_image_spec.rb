# frozen_string_literal: true
require 'rails_helper'
require File.expand_path('../helpers/create_denver_work_user_context', __dir__)

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a DenverImage', js: false do
  include_context 'create denver work user context' do
    let(:work_type) { "denver_image" }

    scenario do
      visit_new_work_page
      add_files_to_work
      add_metadata_to_work
      apply_work_visibility
      check_agreement_and_submit
    end
  end
end
