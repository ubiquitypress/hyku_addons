class AddBulkFlagToBulkraxEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :bulkrax_entries, :bulk, :boolean, default: false, null: false, index: true
  end
end
