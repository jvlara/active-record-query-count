require 'active_support/notifications'
require_relative 'active_record_query_count/version'
require_relative 'active_record_query_count/configuration'
require_relative 'active_record_query_count/printer/base'
require_relative 'active_record_query_count/printer/console'
require_relative 'active_record_query_count/printer/html'
require_relative 'active_record_query_count/recording/base'
require_relative 'active_record_query_count/recording/tracker'
require_relative 'active_record_query_count/compare/comparator'
require_relative 'active_record_query_count/middleware'
require_relative 'active_record_query_count/printer/html_compare'

module ActiveRecordQueryCount
  extend Recording::Base
  if defined?(Rails::Railtie)
    class QueryTrackerRailtie < Rails::Railtie
      initializer 'active_record_query_count.configure_rails_initialization' do |app|
        app.middleware.use Middleware
      end
    end
  end

  class << self
    def configure
      yield(Configuration)
    end

    def tracker
      Thread.current[:query_counter_data] ||= Tracker.new
    end

    def compare
      comparator = Compare::Comparator.new
      yield(comparator)
    end
  end
end
