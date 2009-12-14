class AddDataSystems < ActiveRecord::Migration
  def self.up
    System.delete_all
    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "systems")
  end

  def self.down
    System.delete_all
  end
end
