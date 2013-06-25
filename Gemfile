source 'https://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '2.3.18'
gem "tzinfo", "~> 0.3.31" 

# Supported DBs
gem "pg", :group => :postgresql
gem "activerecord-mysql2-adapter", :group => :mysql

gem 'rake', '~> 10.0'
gem 'test-unit', '1.2.3'
gem 'rmagick', '2.13.2'
gem 'gettext', '2.1.0'
gem 'gruff', '0.3.6'
gem 'webmock', '>= 1.8.7'
gem 'thoughtbot-factory_girl', '1.2.2'
gem 'json'
gem 'daemons'
gem 'moji'
gem 'thinreports'

gem 'acts_as_list', :git => 'git://github.com/swanandp/acts_as_list.git', :ref => '819c37df1a5cacb5990a5c2cb923531e570203f'
gem 'acts_as_tree', '0.1.1'
gem 'ar_fixtures'
gem 'jpmobile', '0.0.8'
gem 'resource_controller'
gem 'will_paginate', '~> 2.3'

# 下記URLから取得したgemを展開して同梱したものからインストール
# http://www.artonx.org/data/lhalib/lhalib-0.8.1.gem
gem 'lhalib', '0.8.1', :path => 'vendor/gems/lhalib-0.8.1'

# bundlerからのインストールがサポートされないのでプラグインとして同梱する
#gem 'ssl_requirement'
#gem 'rails-active-form', :git => 'git://github.com/realityforge/rails-active-form.git'
#gem 'acts_as_paranoid', :git => 'git://github.com/technoweenie/acts_as_paranoid.git'
#gem 'mbmail', :git => 'git://github.com/tmtysk/mbmail.git'
#gem 'double_submit_protection', :git => 'git://github.com/herval/double_submit_protection.git'
#gem 'image_submit_tag_ext', :git => 'git://github.com/champierre/image_submit_tag_ext.git'

group :development do
  gem 'pry'
  gem 'pry-doc'
  gem 'debugger', :require => 'ruby-debug'
end

group :test do
  gem 'rspec-rails', '1.2.9'
  gem 'rspec', '1.2.9'
  gem 'database_cleaner'
  gem 'coveralls', require: false
end
