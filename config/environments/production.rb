# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new
config.logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log", 'daily')

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store
 config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
config.action_mailer.raise_delivery_errors = false

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :domain => 'localhost',
  :address => 'localhost',
  :port => 25
}
ActionMailer::Base.default_charset = 'iso-2022-jp'
 
config.log_level = :debug

