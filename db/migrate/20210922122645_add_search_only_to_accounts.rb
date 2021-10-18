# frozen_string_literal: true
class AddSearchOnlyToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :search_only, :boolean, default: false
  end
end
