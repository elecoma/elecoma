class AddDataOccupations < ActiveRecord::Migration
  def self.up
    Occupation.delete_all
    
    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "occupations")
  end

  def self.down
    Occupation.delete_all
  end
end
