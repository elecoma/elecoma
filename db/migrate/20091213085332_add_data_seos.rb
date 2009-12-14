class AddDataSeos < ActiveRecord::Migration
  def self.up
    Seo.delete_all
    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "seos")
  end

  def self.down
    Seo.delete_all
  end
end
