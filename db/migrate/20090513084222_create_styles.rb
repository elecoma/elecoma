class CreateStyles < ActiveRecord::Migration
  def self.up
    create_table :styles do |t|
      t.column :name, :string, :comment => '規格名'
      t.column :position, :integer, :comment => '順番'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :styles, :deleted_at
    add_index :styles, :position
  end

  def self.down
    remove_index :styles, :position
    remove_index :styles, :deleted_at
    drop_table :styles
  end
end
