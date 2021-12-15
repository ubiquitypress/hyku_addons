# frozen_string_literal: true
class AddDisplayProfileToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :display_profile, :boolean, default: false
  end
end
