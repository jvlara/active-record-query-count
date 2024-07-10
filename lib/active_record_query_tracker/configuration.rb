require 'active_support'
require 'active_support/core_ext/module/attribute_accessors'

module ActiveRecordQueryTracker
  module Configuration
    mattr_accessor :ignore_table_count, :max_locations_per_table, :enable_middleware

    self.ignore_table_count = ENV['QUERY_COUNTER_IGNORE_TABLE_COUNT'] || 10
    self.max_locations_per_table = ENV['MAX_LOCATIONS_PER_TABLE'] || 3
    self.enable_middleware = false
  end
end
