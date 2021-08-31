# frozen_string_literal: true
require 'rails_helper'
require File.expand_path('../helpers/create_redlands_work_user_context', __dir__)

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a RedlandsOpenEducationalResource', js: false do
  include_context 'create redlands work user context' do
    let(:work_type) { "redlands_open_educational_resource" }

    scenario do
      visit_new_work_page
      add_files_to_work
      add_metadata_to_work
      apply_work_visibility
      check_agreement_and_submit
    end
  end
end
