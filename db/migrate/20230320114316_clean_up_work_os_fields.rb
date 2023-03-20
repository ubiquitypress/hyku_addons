class CleanUpWorkOsFields < ActiveRecord::Migration[5.2]
  def change

    if column_exists?(:accounts, :work_os_orgnaisation)
      rename_column :accounts, :work_os_orgnaisation, :work_os_organisation
    end

    if column_exists?(:accounts,:work_os_connection_id)
      rename_column :accounts, :work_os_connection_id, :work_os_connection
    end

  end
end
