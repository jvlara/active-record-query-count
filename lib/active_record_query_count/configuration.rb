require 'active_support/core_ext/module/attribute_accessors'

module ActiveRecordQueryCount
  module Configuration
    mattr_accessor :ignore_table_count, :max_locations_per_table, :enable_middleware

    self.ignore_table_count = 1
    self.max_locations_per_table = 4
    self.enable_middleware = false

    def self.enable_middleware
      ENV['ENABLE_QUERY_COUNT'] == 'true' || @@enable_middleware
    end

    def self.max_locations_per_table
      ENV['QUERY_COUNT_MAX_LOCATIONS_PER_TABLE'] || @@max_locations_per_table
    end

    def self.ignore_table_count
      ENV['QUERY_COUNT_IGNORE_TABLE_COUNT'] || @@ignore_table_count
    end

    def self.unlimited_locations_per_table?
      max_locations_per_table.zero?
    end
  end
end
