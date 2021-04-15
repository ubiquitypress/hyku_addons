# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserOrcidIdentity, type: :model do
  it { should validate_presence_of(:access_token) }
  it { should validate_presence_of(:token_type) }
  it { should validate_presence_of(:refresh_token) }
  it { should validate_presence_of(:expires_in) }
  it { should validate_presence_of(:scope) }
  it { should validate_presence_of(:orcid_id) }

  it { should belong_to(:user).class_name("User") }
end
