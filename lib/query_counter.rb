require 'active_support/notifications'
require_relative 'query_counter/version'
require_relative 'query_counter/configuration'
require_relative 'query_counter/printer/base'
require_relative 'query_counter/printer/console'
require_relative 'query_counter/printer/html'
require_relative 'query_counter/recording/base'
require_relative 'query_counter/recording/tracker'
require_relative 'query_counter/compare/comparator'
require_relative 'query_counter/middleware'
require_relative 'query_counter/printer/html_compare'
module QueryCounter
  extend Recording::Base
  if defined?(Rails::Railtie)
    class QueryCounterRailtie < Rails::Railtie
      initializer 'query_counter.configure_rails_initialization' do |app|
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