# This migration comes from comable (originally 20140723175810)
class CreateComableOrderItems < ActiveRecord::Migration
  def change
    create_table :comable_order_items do |t|
      t.references :order, null: false
      t.references :stock, null: false
      t.string :name, null: false
      t.string :code, null: false
      t.integer :price, null: false
      t.string :sku_h_item_name
      t.string :sku_v_item_name
      t.string :sku_h_choice_name
      t.string :sku_v_choice_name
      t.integer :quantity, default: 1, null: false
    end

    add_index :comable_order_items, [:order_id, :stock_id], unique: true, name: :comable_order_items_idx_01
  end
end
