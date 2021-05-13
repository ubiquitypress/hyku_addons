# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificImage`
require 'rails_helper'
require File.expand_path('../helpers/create_pacific_work_user_context', __dir__)

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a PacificImage', js: false do
  before do
    optional "fails randomnly on CI" if ENV["CI"]
  end

  include_context 'create pacific work user context' do
    let(:work_type) { "pacific_image" }

    scenario do
      visit_new_work_page
      add_files_to_work
      add_metadata_to_work
      apply_work_visibility
      check_agreement_and_submit
    end
  end
end
