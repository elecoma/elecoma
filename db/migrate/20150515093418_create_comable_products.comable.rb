# This migration comes from comable (originally 20131214194807)
class CreateComableProducts < ActiveRecord::Migration
  def change
    create_table :comable_products do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :price, null: false
      t.text :caption
      t.string :sku_h_item_name
      t.string :sku_v_item_name
    end

    add_index :comable_products, :code, unique: true, name: :comable_products_idx_01
  end
end
