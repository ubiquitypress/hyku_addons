class AddWorkosConnectionIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :work_os_connection_id, :string
  end
end
