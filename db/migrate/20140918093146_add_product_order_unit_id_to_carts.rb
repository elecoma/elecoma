class AddProductOrderUnitIdToCarts < ActiveRecord::Migration
  def self.up
    add_column :carts, :product_order_unit_id, :integer
  end

  def self.down
    remove_column :carts, :product_order_unit_id
  end
end
