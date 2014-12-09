class AddProductOrderUnitIdToReturnItems < ActiveRecord::Migration
  def self.up
    add_column :return_items, :product_order_unit_id, :integer
  end

  def self.down
    remove_column :return_items, :product_order_unit_id
  end
end
