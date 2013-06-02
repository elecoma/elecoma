# -*- coding: utf-8 -*-
# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'gettext'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"

  config.gem 'thinreports'
 
 # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  #config.time_zone = 'UTC'
  #config.time_zone = 'Tokyo'
  config.active_record.default_timezone = 'Tokyo' 

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = 'ja'

  config.action_controller.session = {:cookie_only => false}
end

module ActionView
  class Base
    delegate :file_exists?, :to => :finder unless respond_to?(:file_exists?)
  end
end

require 'action_view_helper'
require 'active_record_helper'
require 'will_paginate'
require 'validates'
require 'rexml-expansion-fix'
require 'create_fixtures'
require 'security_token'
require 'csv_util'
require 'check_session_signature'

list = Dir["app/models/*.rb"]
list.each do |i|
  model = Object.const_get(File.basename(i, '.rb').camelize)
  if model.superclass == ActiveRecord::Base && model.table_exists?
    model.new
  end
end

# unsuported_device_mobile.html.erb で使用されるページネーションレンダラ
class UnsupportedDeviceLinkRenderer < WillPaginate::LinkRenderer
  def page_link(page, text, attributes = {})
    @template.link_to text, url_for(page), {}
  end

  def page_span(page, text, attributes = {})
#    @template.content_tag :span, text, {}
  end  
end

require "#{RAILS_ROOT}/lib/jpmobile/mobile/smartphone.rb"
carriers = Jpmobile::Mobile.carriers
Jpmobile::Mobile.carriers = carriers.push("Smartphone")
