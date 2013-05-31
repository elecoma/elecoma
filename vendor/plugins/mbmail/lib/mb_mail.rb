require 'rubygems'
require 'nkf'
require 'scanf'

#Dir[File.join(File.dirname(__FILE__), 'tmail/**/*.rb')].sort.each { |f| require f }
Dir[File.join(File.dirname(__FILE__), 'jpmobile/**/*.rb')].sort.each { |f| require f }
Dir[File.join(File.dirname(__FILE__), 'mb_mail/**/*.rb')].sort.each { |f| require f }
