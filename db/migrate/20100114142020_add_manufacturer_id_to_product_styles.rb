class AddManufacturerIdToProductStyles < ActiveRecord::Migration
  def self.up
    add_column :product_styles, :manufacturer_id, :string, :comment => "型番"    
  end

  def self.down
    remove_columns :product_styles, :manufacturer_id
  end
end
