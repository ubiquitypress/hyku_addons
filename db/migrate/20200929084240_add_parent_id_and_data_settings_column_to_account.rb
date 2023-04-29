# frozen_string_literal: true
class AddParentIdAndDataSettingsColumnToAccount < ActiveRecord::Migration[5.2]
  def change
    add_reference :accounts, :parent, foreign_key: { to_table: :accounts } unless column_exists?(:accounts, :parent_id)
    add_column :accounts, :settings, :jsonb, default: {} unless column_exists?(:accounts, :settings)
    add_column :accounts, :data, :jsonb, default: {} unless column_exists?(:accounts, :data)
    add_index  :accounts, :settings, using: :gin unless index_exists?(:accounts, :settings)
    add_index  :accounts, :data, using: :gin unless index_exists?(:accounts, :data)
  end
end
