require 'spec'
require 'action_controller'
require 'action_mailer'
require File.dirname(__FILE__) + "/../lib/mb_mail.rb"
SAMPLE_DIR = "#{File.dirname(__FILE__)}/sample"
INVALID_ADDRESS = 'test...test...@example.com'
