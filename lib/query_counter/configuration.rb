require 'active_support'
require 'active_support/core_ext/module/attribute_accessors'

module QueryCounter
  module Configuration
    mattr_accessor :ignore_table_count, :max_locations_per_table

    self.ignore_table_count = ENV['QUERY_COUNTER_IGNORE_TABLE_COUNT'] || 10
    self.max_locations_per_table = ENV['MAX_LOCATIONS_PER_TABLE'] || 3
  end
end