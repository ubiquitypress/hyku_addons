class CreateHykuAddonsUbiquitousContents < ActiveRecord::Migration[5.2]
  def change
    create_table :hyku_addons_ubiquitous_contents do |t|
      t.string :content_type, index: true
      t.string :content_id
      t.integer :limit
      t.string :order
      t.text :conditions

      t.timestamps
    end
  end
end
