# frozen_string_literal: true

class AddSearchOnlyToAccounts < ActiveRecord::Migration[5.2]
  def self.up
    add_column :accounts, :search_only, :boolean, default: false unless column_exists?(:accounts, :search_only)
  end

  def self.down
    remove_column :accounts, :search_only if column_exists?(:accounts, :search_only)
  end
end
