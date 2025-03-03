# frozen_string_literal: true

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
require 'launchy'
require 'nokogiri'

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

def assert_html_message_presence(data, message, should_include)
  if should_include
    assert_includes(query_counter_report_div(data), message)
  else
    refute_includes(query_counter_report_div(data), message)
  end
end

def query_counter_report_div(data)
  html_printer = ActiveRecordQueryCount::Printer::Html.new(data: data)
  rendered_html = html_printer.render_query_counter_base_div
  doc = Nokogiri::HTML(rendered_html)
  doc.at_xpath('//*[@id="query_counter_report_gem"]').to_s
end

def assert_console_message_presence(data, message, should_include)
  output = capture_stdout do
    ActiveRecordQueryCount::Printer::Console.new(data: data).print
  end

  if should_include
    assert_includes(output, message)
  else
    refute_includes(output, message)
  end
end

def capture_stdout
  original_stdout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = original_stdout
end
