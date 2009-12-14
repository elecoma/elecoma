load "/home/ec/trunk/pack/god/common.god"
RAILS_ENV = "production"

%w{3000 3001 3002 3003 3004 3005}.each do |port|
  God.watch do |w|
    watch_kill("ec_response", "ec", "ec", w, port, "/home/ec/trunk/pack/", RAILS_ENV)
  end
  God.watch do |w|
    watch_restart("ec_process_memory", "ec", "ec", w, port, "/home/ec/trunk/pack/", RAILS_ENV)
  end
end
