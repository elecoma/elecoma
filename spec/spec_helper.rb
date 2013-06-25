# -*- coding: utf-8 -*-
ENV["RAILS_ENV"] ||= 'test'
require 'coveralls'
Coveralls.wear!('rails')

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require 'database_cleaner'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.global_fixtures = :authorities, :functions, :authorities_functions, :systems

  # テストがDBの状態に依存するのを防ぐ
  # (ただし複数のspecファイルを実行するとすべてのfixturesメソッドが先読みされるためDB依存は避けられない)
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

# Date を date_select の形にする
def date_to_select date, name
  {
    name+'(1i)' => date.strftime('%Y'),
    name+'(2i)' => date.strftime('%m'),
    name+'(3i)' => date.strftime('%d')
  }
end

# ファイルアップロード
def uploaded_file(path, content_type, filename)
  t = Tempfile.new(filename);
  FileUtils.copy_file(path, t.path)
  (class << t; self; end).class_eval do
    alias local_path path
    define_method(:original_filename) {filename}
    define_method(:content_type) {content_type}
  end
  return t
end

# DateTime を date_select の形にする
def datetime_to_select datetime, name
  {
    name+'(1i)' => datetime.strftime('%Y'),
    name+'(2i)' => datetime.strftime('%m'),
    name+'(3i)' => datetime.strftime('%d'),
    name+'(4i)' => datetime.strftime('%H'),
    name+'(5i)' => datetime.strftime('%M')
  }
end

def array_to_time array, name
  {
    name+'(1i)' => array[0],
    name+'(2i)' => array[1],
    name+'(3i)' => array[2]
  }
end

