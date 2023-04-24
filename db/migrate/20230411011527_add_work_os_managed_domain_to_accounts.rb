class AddWorkOsManagedDomainToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :work_os_managed_domain, :string
  end
end
