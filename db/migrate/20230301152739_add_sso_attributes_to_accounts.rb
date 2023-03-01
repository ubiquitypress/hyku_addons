class AddSsoAttributesToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :enable_sso, :boolean
    add_column :accounts, :work_os_orgnaisation, :string
  end
end
