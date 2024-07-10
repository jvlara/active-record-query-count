require 'active_support/notifications'
require_relative 'query_tracker/version'
require_relative 'query_tracker/configuration'
require_relative 'query_tracker/printer/base'
require_relative 'query_tracker/printer/console'
require_relative 'query_tracker/printer/html'
require_relative 'query_tracker/recording/base'
require_relative 'query_tracker/recording/tracker'
require_relative 'query_tracker/compare/comparator'
require_relative 'query_tracker/middleware'
require_relative 'query_tracker/printer/html_compare'
module QueryTracker
  extend Recording::Base
  if defined?(Rails::Railtie)
    class QueryTrackerRailtie < Rails::Railtie
      initializer 'query_tracker.configure_rails_initialization' do |app|
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
