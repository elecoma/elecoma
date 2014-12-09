class AddProductOrderUnitIdToFavorites < ActiveRecord::Migration
  def self.up
    add_column :favorites, :product_order_unit_id, :integer
  end

  def self.down
    remove_column :favorites, :product_order_unit_id
  end
end
