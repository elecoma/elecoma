class AddDeliveryIdToProductOrderUnits < ActiveRecord::Migration
  def self.up
    add_column :product_order_units, :order_delivery_id, :integer
  end

  def self.down
    remove_column :product_order_units, :order_delivery_id
  end
end
