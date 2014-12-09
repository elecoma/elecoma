class CreateProductOrderUnits < ActiveRecord::Migration
  def self.up
    create_table :product_order_units do |t|
      t.boolean :set_flag
      t.integer :product_style_id
      t.integer :product_set_id
      t.integer :sell_price
      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :product_order_units
  end
end
