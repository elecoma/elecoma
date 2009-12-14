class CreateOrderDetails < ActiveRecord::Migration
  def self.up
    create_table :order_details do |t|
      t.column :product_id,             :integer, :comment => '商品ID'
      t.column :classcategory_id1,      :integer, :comment => '規格分類ID1'
      t.column :classcategory_id2,      :integer, :comment => '規格分類ID2'
      t.column :product_name,           :string,  :comment => '商品名'
      t.column :product_code,           :string,  :comment => '商品コード'
      t.column :style_name1,            :string,  :comment => '規格名1'
      t.column :style_name2,            :string,  :comment => '規格名2'
      t.column :price,                  :integer, :comment => '価格'
      t.column :quantity,               :integer, :comment => '個数'
      t.column :point_rate,             :integer, :comment => 'ポイント付与率'
      t.column :product_category_id,    :integer, :comment => '商品カテゴリ'
      t.column :order_delivery_id,      :integer, :comment => '配達要望ID'
      t.column :product_style_id,       :integer, :comment => '商品スタイルID'
      t.column :position,               :integer, :comment => '順番'
      t.column :style_category_name1,   :string, :comment => '規格分類名1'
      t.column :style_category_name2,   :string, :comment => '規格分類名2'
      t.column :tax_price, :integer,    :comment => '消費税額'
      t.column :created_at, :datetime,  :comment => '作成日'
      t.column :updated_at, :datetime,  :comment => '更新日'
      t.column :deleted_at, :datetime,  :comment => '削除日'
    end
    add_index :order_details, :deleted_at
    add_index :order_details, :classcategory_id1
    add_index :order_details, :classcategory_id2
    add_index :order_details, :order_delivery_id
    add_index :order_details, :product_category_id
    add_index :order_details, :product_id
    add_index :order_details, :product_style_id
    add_index :order_details, :position
  end

  def self.down
    remove_index :order_details, :position
    remove_index :order_details, :classcategory_id1
    remove_index :order_details, :classcategory_id2
    remove_index :order_details, :order_delivery_id
    remove_index :order_details, :product_category_id
    remove_index :order_details, :product_id
    remove_index :order_details, :product_style_id
    remove_index :order_details, :deleted_at
    drop_table :order_details
  end
end
