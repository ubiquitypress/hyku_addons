# frozen_string_literal: true

class AddDisplayProfileToUsers < ActiveRecord::Migration[5.2]
  def self.up
    add_column :users, :display_profile, :boolean, default: false unless column_exists?(:users, :display_profile)
  end

  def self.down
    remove_column :users, :display_profile if column_exists?(:users, :display_profile)
  end
end
