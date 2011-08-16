require File.dirname(__FILE__) + '/../../config/boot'
require 'rubygems'
require 'daemons'

def daemon_run(running_command, mode = "run", rails_env = "production", daemon_name = nil, prefix = "Prefix::")
  if daemon_name.nil?
    daemon_name = running_command
  end
  argv = [mode, "--", "-e", rails_env, running_command]
  Daemons.run(
    "#{RAILS_ROOT}/script/runner",
    :ARGV => argv,
    :app_name => prefix.to_s + daemon_name.to_s,
    :dir_mode => :script,
    :dir => "../log",
    :multiple   => true,
    :keep_pid_files => false
  )
end
