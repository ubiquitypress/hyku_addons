# frozen_string_literal: true
class AddParentIdAndDataSettingsColumnToAccount < ActiveRecord::Migration[5.2]
  def change
    add_reference :accounts, :parent, foreign_key: { to_table: :accounts }
    add_column :accounts, :settings, :jsonb, default: {}
    add_column :accounts, :data, :jsonb, default: {}
    add_index  :accounts, :settings, using: :gin
    add_index  :accounts, :data, using: :gin
  end
end
