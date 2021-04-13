class UserOrcidAuthorizationIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :user_orcid_authorizations, :orcid_id
  end
end
