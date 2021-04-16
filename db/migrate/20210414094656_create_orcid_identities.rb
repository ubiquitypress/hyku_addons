# frozen_string_literal: true

class CreateOrcidIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :orcid_identities do |t|
      t.belongs_to :user
      t.string :name
      t.string :access_token, index: true
      t.string :token_type
      t.string :refresh_token
      t.integer :expires_in
      t.string :scope
      t.string :orcid_id, index: true

      t.timestamps
    end
  end
end
