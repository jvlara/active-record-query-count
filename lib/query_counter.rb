# frozen_string_literal: true

require_relative "query_counter/version"
require 'colorize'
require 'active_support/notifications'

class QueryCounter
  REGEX_TABLE_SQL = /FROM\s+"(?<table>[^"]+)"/
  IGNORE_TABLE_COUNT = ENV['QUERY_COUNTER_IGNORE_TABLE_COUNT'] || 10
  MAX_LOCATIONS_PER_TABLE = ENV['MAX_LOCATIONS_PER_TABLE'] || 3

  attr_accessor :query_count
  attr_accessor :suscription

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
      singleton_instance.print
    end
  end
  extend ClassMethods

  def initialize
    @query_count = Hash.new { |hash, key| hash[key] = {count: 0, location: Hash.new(0)} }
  end

  def reset_query_count
    query_count = Hash.new { |hash, key| hash[key] = {count: 0, location: Hash.new(0)} }
  end

  def display_data(data)
    puts "[QueryCounter] Cantidad de queries por tabla:".colorize(:blue)
    puts "Cantidad total de queries: #{data.values.sum { |v| v[:count] }}\n\n"
    puts "Se ignoran todas las tablas con menos de #{IGNORE_TABLE_COUNT} queries. \n\n"
    puts "Por cada tabla se muestrarán las #{MAX_LOCATIONS_PER_TABLE} ubicaciones con más queries.\n\n"
    data.sort_by{|_, v| -v[:count] }.each do |category, info|
      puts "Tabla #{category.colorize(:cyan)}"
      puts "  Cantidad total de queries: #{info[:count].to_s.colorize(:blue)}"
      puts "  Lugares donde se llamo a la tabla:"
      info[:location].sort_by{|_, v| -v }.each do |loc, count|
        location_display = loc.nil? ? 'None' : loc
        puts "    - Lugar: #{location_display}"
        puts "        Cantidad de queries: #{count.to_s.colorize(:blue)}"
      end
      puts
    end
  end

  def subscribe
    return unless suscription.nil?
    suscription = ActiveSupport::Notifications.subscribe("sql.active_record") do |a, b, c, d, payload|
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
    ActiveSupport::Notifications.unsubscribe(suscription)
    suscription = nil
  end
end
