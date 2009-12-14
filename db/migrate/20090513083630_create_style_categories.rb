class CreateStyleCategories < ActiveRecord::Migration
  def self.up
    create_table :style_categories do |t|
      t.column :name, :string, :comment => '規格分類名'
      t.column :position, :integer, :comment => '順番'
      t.column :style_id, :integer, :comment => '規格ID'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :style_categories, :deleted_at
    add_index :style_categories, :position
    add_index :style_categories, :style_id
  end

  def self.down
    remove_index :style_categories, :style_id
    remove_index :style_categories, :position
    remove_index :style_categories, :deleted_at
    drop_table :style_categories
  end
end
