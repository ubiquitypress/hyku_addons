# frozen_string_literal: true

class OrcidWork < ApplicationRecord
  belongs_to :orcid_identity

  validates_presence_of :work_uuid, :put_code
  validates_associated :orcid_identity
end

