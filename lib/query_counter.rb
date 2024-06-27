require 'active_support/notifications'
require_relative 'query_counter/version'
require_relative 'query_counter/configuration'
require_relative 'query_counter/printer/base'
require_relative 'query_counter/printer/console'
require_relative 'query_counter/printer/html'
require_relative 'query_counter/recording/base'
require_relative 'query_counter/recording/tracker'

module QueryCounter
  extend Recording::Base

  class << self
    def configure
      yield(Configuration)
    end

    def tracker
      @tracker ||= Tracker.new
    end
  end
end