# frozen_string_literal: true

class UserOrcidIdentity < ApplicationRecord
  belongs_to :user

  validates :access_token, :token_type, :refresh_token, :expires_in, :scope, :orcid_id, presence: true
  validates_associated :user
end
