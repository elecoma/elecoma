class AddDataStatuses < ActiveRecord::Migration
  def self.up
    Status.delete_all
    
    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "statuses")
  end

  def self.down
    Status.delete_all
  end
end
