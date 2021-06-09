class CreateHykuAddonsHykuAddonsUbiquitousPages < ActiveRecord::Migration[5.2]
  def change
    create_table :hyku_addons_ubiquitous_pages do |t|
      t.string :name
      t.jsonb :matcher, default: {}
      t.boolean :disabled_at, index: true
      t.integer :grid_columns_count, default: 4
      t.string :path_matcher
      t.timestamps
    end
  end
end
