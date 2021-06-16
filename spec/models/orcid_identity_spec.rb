# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrcidIdentity, type: :model do
  let(:work_sync_preference) { { sync_all: 0, sync_notify: 1, manual: 2 } }

  it { is_expected.to validate_presence_of(:access_token) }
  it { is_expected.to validate_presence_of(:token_type) }
  it { is_expected.to validate_presence_of(:refresh_token) }
  it { is_expected.to validate_presence_of(:expires_in) }
  it { is_expected.to validate_presence_of(:scope) }
  it { is_expected.to validate_presence_of(:orcid_id) }
  it { is_expected.to define_enum_for(:work_sync_preference).with_values(work_sync_preference) }
  it { is_expected.to belong_to(:user).class_name("User") }
  it { is_expected.to have_many(:orcid_works) }
end
