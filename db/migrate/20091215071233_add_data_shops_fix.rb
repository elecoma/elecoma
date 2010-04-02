class AddDataShopsFix < ActiveRecord::Migration
  def self.up
    Shop.delete_all!
    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "shops")
  end

  def self.down
    Shop.delete_all!
  end
end
