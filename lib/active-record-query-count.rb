module ActiveRecordQueryCount
  autoload :VERSION,       'active_record_query_count/version'
  autoload :Configuration, 'active_record_query_count/configuration'
  autoload :Middleware,    'active_record_query_count/middleware'

  module Printer
    autoload :Base,        'active_record_query_count/printer/base'
    autoload :Console,     'active_record_query_count/printer/console'
    autoload :Html,        'active_record_query_count/printer/html'
    autoload :HtmlCompare, 'active_record_query_count/printer/html_compare'
  end

  module Recording
    autoload :Base,    'active_record_query_count/recording/base'
    autoload :Tracker, 'active_record_query_count/recording/tracker'
  end

  module Compare
    autoload :Comparator, 'active_record_query_count/compare/comparator'
  end

  extend Recording::Base

  if defined?(Rails::Railtie)
    class QueryCountRailtie < Rails::Railtie
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
      Thread.current[:query_counter_data] ||= Recording::Tracker.new
    end

    def compare
      comparator = Compare::Comparator.new
      yield(comparator)
    end
  end
end
