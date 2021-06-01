# frozen_string_literal: true

class OrcidIdentity < ApplicationRecord
  enum work_sync_preference: { sync_all: 0, sync_primary_and_ask: 1, ask_all: 2 }

  belongs_to :user

  validates :access_token, :token_type, :refresh_token, :expires_in, :scope, :orcid_id, presence: true
  validates_associated :user

  def self.profile_sync_preference
    %i[employment funding education works distinctions websites memberships other].freeze
  end
end
