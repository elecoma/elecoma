class CreateProductStatuses < ActiveRecord::Migration
  def self.up
    create_table :product_statuses do |t|
      t.column :product_id, :integer,   :comment => '商品ID'
      t.column :status_id,  :integer,   :comment => 'ステータスID'
      t.column :position,   :integer,   :comment => '順番'
      t.column :created_at, :datetime,  :comment => '作成日'
      t.column :updated_at, :datetime,  :comment => '更新日'
      t.column :deleted_at, :datetime,  :comment => '削除日'
    end
    add_index :product_statuses, :deleted_at
    add_index :product_statuses, :position
    add_index :product_statuses, :status_id
  end

  def self.down
    remove_index :product_statuses, :position
    remove_index :product_statuses, :status_id
    remove_index :product_statuses, :deleted_at
    drop_table :product_statuses
  end
end
