class AddProductOrderUnitIdToRecommendProducts < ActiveRecord::Migration
  def self.up
    add_column :recommend_products, :product_order_unit_id, :integer
  end

  def self.down
    remove_column :recommend_products, :product_order_unit_id
  end
end
