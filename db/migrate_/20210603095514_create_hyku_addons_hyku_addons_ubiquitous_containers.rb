class CreateHykuAddonsHykuAddonsUbiquitousContainers < ActiveRecord::Migration[5.2]
  def change
    create_table :hyku_addons_ubiquitous_containers do |t|
      t.string :name
      t.references :content
      t.integer :style, index: true
      t.string :custom_title
      t.text :custom_description

      t.timestamps
    end
  end
end
