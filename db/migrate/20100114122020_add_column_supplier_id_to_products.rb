class AddColumnSupplierIdToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :supplier_id, :integer,:default => 1, :comment => "仕入先ID"
    Product.update_all("supplier_id = 1")
  end

  def self.down
    remove_columns :products, :supplier_id
  end
end
