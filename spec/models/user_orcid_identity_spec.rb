# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserOrcidIdentity, type: :model do
  it { is_expected.to validate_presence_of(:access_token) }
  it { is_expected.to validate_presence_of(:token_type) }
  it { is_expected.to validate_presence_of(:refresh_token) }
  it { is_expected.to validate_presence_of(:expires_in) }
  it { is_expected.to validate_presence_of(:scope) }
  it { is_expected.to validate_presence_of(:orcid_id) }

  it { is_expected.to belong_to(:user).class_name("User") }
end
