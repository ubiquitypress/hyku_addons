class CreateHykuAddonsHykuAddonsUbiquitousWidgets < ActiveRecord::Migration[5.2]
  def change
    create_table :hyku_addons_ubiquitous_widgets do |t|
      t.string :uuid, index: true
      t.string :name
      t.string :type, index: true
      t.references :container
      t.references :page
      t.integer :position
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
