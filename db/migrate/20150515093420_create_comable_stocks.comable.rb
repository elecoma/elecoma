# This migration comes from comable (originally 20140502060116)
class CreateComableStocks < ActiveRecord::Migration
  def change
    create_table :comable_stocks do |t|
      t.references :product, null: false
      t.string :code, null: false
      t.integer :quantity, null: false, default: 0
      t.string :sku_h_choice_name
      t.string :sku_v_choice_name
    end

    add_index :comable_stocks, :code, unique: true, name: :comable_stocks_idx_01
  end
end
