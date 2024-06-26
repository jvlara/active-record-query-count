# frozen_string_literal: true

require_relative "query_counter/version"
require 'colorize'
require 'active_support/notifications'

class QueryCounter
  REGEX_TABLE_SQL = /FROM\s+"(?<table>[^"]+)"/
  IGNORE_TABLE_COUNT = ENV['QUERY_COUNTER_IGNORE_TABLE_COUNT'] || 10
  MAX_LOCATIONS_PER_TABLE = ENV['MAX_LOCATIONS_PER_TABLE'] || 3

  attr_accessor :query_count
  attr_accessor :subscription

  module ClassMethods
    def singleton_instance
      @singleton_instance ||= QueryCounter.new
    end

    def start_with_block
      if block_given?
        start_recording
        yield
        end_recording
      else
        raise "Block not given"
      end
    end

    def start_recording
      singleton_instance.reset_query_count
      singleton_instance.subscribe
    end

    def end_recording
      singleton_instance.unsubscribe
      singleton_instance.display_data singleton_instance.query_count
    end
  end
  extend ClassMethods

  def initialize
    @query_count = Hash.new { |hash, key| hash[key] = {count: 0, location: Hash.new(0)} }
  end

  def reset_query_count
    @query_count = Hash.new { |hash, key| hash[key] = {count: 0, location: Hash.new(0)} }
  end

  def display_data(data)
    puts "[QueryCounter] Query count per table:".colorize(:blue)
    puts "Total query count: #{data.values.sum { |v| v[:count] }}\n\n"
    puts "All tables with less than #{IGNORE_TABLE_COUNT} queries are ignored. \n\n"
    puts "For each table, the top #{MAX_LOCATIONS_PER_TABLE} locations with the most queries will be shown.\n\n"
    data = data.select { |_, v| v[:count] >= IGNORE_TABLE_COUNT }
    data.sort_by{|_, v| -v[:count] }.each do |category, info|
      puts "Table #{category.colorize(:cyan)}"
      puts "  Total query count: #{info[:count].to_s.colorize(:blue)}"
      puts "  Locations where the table was called:"
      locations = info[:location].sort_by{|_, v| -v }.first(MAX_LOCATIONS_PER_TABLE)
      locations.each do |loc, count|
        location_display = loc.nil? ? 'None' : loc
        puts "    - Location: #{location_display}"
        puts "        Query count: #{count.to_s.colorize(:blue)}"
      end
      puts
    end
  end

  def subscribe
    return unless subscription.nil?
    @subscription = ActiveSupport::Notifications.subscribe("sql.active_record") do |a, b, c, d, payload|
      caller_from_sql = caller
      sql = payload[:sql]
      match = sql.match(REGEX_TABLE_SQL)
      if match.present? && match[:table]
        actual_location = Rails.backtrace_cleaner.clean(caller_from_sql).first
        query_count[match[:table]][:count] += 1
        query_count[match[:table]][:location][actual_location] += 1
      end
    end
  end

  def unsubscribe
    ActiveSupport::Notifications.unsubscribe(@subscription)
    @subscription = nil
  end
end