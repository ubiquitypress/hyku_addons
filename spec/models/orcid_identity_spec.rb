# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrcidIdentity, type: :model do
  it { is_expected.to validate_presence_of(:access_token) }
  it { is_expected.to validate_presence_of(:token_type) }
  it { is_expected.to validate_presence_of(:refresh_token) }
  it { is_expected.to validate_presence_of(:expires_in) }
  it { is_expected.to validate_presence_of(:scope) }
  it { is_expected.to validate_presence_of(:orcid_id) }
  it { is_expected.to define_enum_for(:work_sync_preference).with_values(sync_all: 0, sync_primary_and_ask: 1, ask_all: 2) }
  it { is_expected.to belong_to(:user).class_name("User") }
  it { is_expected.to have_many(:orcid_works) }
end
