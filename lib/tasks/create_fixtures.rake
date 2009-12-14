desc "Save fixtures from the current environment's database"
task :create_fixtures => :environment do
  list = Dir["app/models/*.rb"]
  p list
  list.each do |i|
    eval File.basename(i, '.rb').camelize
  end
  Object.subclasses_of(ActiveRecord::Base).each do |klass| 
    klass.to_fixture rescue p klass.name
  end
end
