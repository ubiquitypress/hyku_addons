class AddNameToUbiquitousContents < ActiveRecord::Migration[5.2]
  def change
    change_table :hyku_addons_ubiquitous_contents do |t|
      t.string :name
    end
  end
end
