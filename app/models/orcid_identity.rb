# frozen_string_literal: true

class OrcidIdentity < ApplicationRecord
  belongs_to :user

  validates :access_token, :token_type, :refresh_token, :expires_in, :scope, :orcid_id, presence: true
  validates_associated :user

  def self.sync_preferences
    %i[employment funding education works distinctions websites memberships other].freeze
  end

  def sync_work(work)
  end
end
