# frozen_string_literal: true

class CreateOrcidWorks < ActiveRecord::Migration[5.2]
  def change
    create_table :orcid_works do |t|
      t.references :orcid_identity
      t.string :work_uuid
      t.integer :put_code

      t.index :work_uuid
    end
  end
end
