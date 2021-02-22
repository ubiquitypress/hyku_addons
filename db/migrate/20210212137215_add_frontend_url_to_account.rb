# frozen_string_literal: true
class AddFrontendUrlToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :frontend_url, :string, default: ''
    add_index  :accounts, :frontend_url
  end
end
