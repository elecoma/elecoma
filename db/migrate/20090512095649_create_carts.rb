class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
      t.column :customer_id, :integer, :comment => '顧客ID'
      t.column :quantity, :integer, :comment => '個数'
      t.column :position, :integer, :comment => '順番'
      t.column :created_at, :datetime, :comment => '作成日'
      t.column :updated_at, :datetime, :comment => '更新日'
      t.column :product_style_id, :integer, :comment => '商品ID'
      t.column :deleted_at, :datetime, :comment => '削除日'
      t.column :campaign_id, :integer, :comment => 'キャンペーンID'
      t.column :aff_id, :string, :comment => 'アフィリエイトID'
    end
    add_index :carts, :customer_id
    add_index :carts, :deleted_at
  end

  def self.down
    remove_index :carts, :deleted_at
    remove_index :carts, :customer_id
    drop_table :carts
  end
end
