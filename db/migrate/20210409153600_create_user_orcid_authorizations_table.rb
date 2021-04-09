# frozen_string_literal: true
class CreateUserOrcidAuthorizationsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :user_orcid_authorizations do |t|
      t.belongs_to :user
      t.string :access_token, index: true
      t.string :token_type
      t.string :refresh_token
      t.integer :expires_in
      t.string :scope
      t.string :orcid_id
      t.timestamps
    end
  end
end
