require File.dirname(__FILE__) + '/../../config/boot'
require "#{RAILS_ROOT}/lib/daemons/base.rb"
require 'optparse'

opt = OptionParser.new
OPTS = {}
OPTS[:env] = 'development'

opt.on('-e environment', "\tSpecifies the environment for mail daemon [production/development/test] \n\t\t\t\t\tDefault: #{OPTS[:env]}") {|v| OPTS[:env] = v}

opt.banner = "Usage: mail [options] {start|stop|run}"

opt.parse!(ARGV)


type = "start"
if ARGV[0] && ["start", "stop", "run"].index(ARGV[0])
  type = ARGV[0]
end

daemon_run("Mail.do_daemon", type, OPTS[:env])
