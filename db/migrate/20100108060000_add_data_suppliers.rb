class AddDataSuppliers < ActiveRecord::Migration
  def self.up
    Supplier.delete_all
    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "suppliers")
  end

  def self.down
    Supplier.delete_all
  end
end
