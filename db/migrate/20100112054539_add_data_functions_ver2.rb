class AddDataFunctionsVer2 < ActiveRecord::Migration
  def self.up
    Function.delete_all
    Authority.delete_all
    execute("delete from authorities_functions")

    
    directory = File.join(File.dirname(__FILE__), "fixed_data")
    Fixtures.create_fixtures(directory, "authorities")
    Fixtures.create_fixtures(directory, "functions")
    Fixtures.create_fixtures(directory, "authorities_functions")
  end

  def self.down
    Function.delete_all
    execute("delete from authorities_functions")
    Authority.delete_all
  end
end
