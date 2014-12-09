class AddProductOrderUnitToOrderDetails < ActiveRecord::Migration
  def self.up
    add_column :order_details, :product_style_ids, :string
    add_column :order_details, :ps_counts, :string
  end

  def self.down
    remove_column :order_details, :ps_counts
    remove_column :order_details, :product_style_ids
  end
end
