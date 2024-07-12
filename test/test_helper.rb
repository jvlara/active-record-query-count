# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

ENV['RACK_ENV'] ||= 'test'

require 'bundler/setup'
Bundler.require(:default, :development, ENV['RACK_ENV'] || :development)

require 'minitest/autorun'
require 'mocha/minitest'
require 'shoulda/matchers'
require 'active-record-query-count'
require 'active_record'
require 'active_support'
require 'active_support/notifications'
require 'sqlite3'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :active_record
  end
end

# Configure ActiveRecord to use an in-memory SQLite database
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Define a simple schema for testing
ActiveRecord::Schema.define do
  create_table :test_models, force: true do |t|
    t.string :name
  end
end

# Define a simple ActiveRecord model for testing
class TestModel < ActiveRecord::Base
end

# Stub Rails.backtrace_cleaner
module Rails
  def self.backtrace_cleaner
    Class.new do
      def self.clean(caller_from_sql)
        caller_from_sql.select { |path| path.include?('/test/') }.map { |path| path.gsub(Dir.home, '') }
      end
    end
  end
end
