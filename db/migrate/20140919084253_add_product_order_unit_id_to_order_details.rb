class AddProductOrderUnitIdToOrderDetails < ActiveRecord::Migration
  def self.up
    add_column :order_details, :product_order_unit_id, :integer
  end

  def self.down
    remove_column :order_details, :product_order_unit_id
  end
end
