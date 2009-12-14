class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.column :product_id, :integer, :comment => '商品ID'
      t.column :name, :string, :comment => 'ステータス名'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :deleted_at, :datetime, :comment => '削除日'
    end
    add_index :statuses, :deleted_at
    add_index :statuses, :product_id
  end

  def self.down
    remove_index :statuses, :product_id
    remove_index :statuses, :deleted_at
    drop_table :statuses
  end
end
