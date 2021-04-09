#frozen_string_literal: true

class UserOrcidAuthorization < ApplicationRecord
  self.table_name = :user_orcid_authorizations
  belongs_to :user
end
