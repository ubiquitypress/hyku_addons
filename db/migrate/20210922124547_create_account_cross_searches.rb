# frozen_string_literal: true
class CreateAccountCrossSearches < ActiveRecord::Migration[5.2]
  def self.up
    return if table_exists?(:account_cross_searches)

    create_table :account_cross_searches do |t|
      t.references :search_account, foreign_key: { to_table: :accounts }
      t.references :full_account, foreign_key: { to_table: :accounts }

      t.timestamps
    end
  end

  def self.down
    drop_table(:account_cross_searches)
  end
end
