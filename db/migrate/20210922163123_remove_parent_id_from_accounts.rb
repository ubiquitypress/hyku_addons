# frozen_string_literal: true
class RemoveParentIdFromAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_reference :accounts, :parent, foreign_key: { to_table: :accounts }
  end
end
