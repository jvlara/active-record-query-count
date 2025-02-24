require 'active_support/notifications'

module ActiveRecordQueryCount
  module Recording
    class Tracker
      REGEX_TABLE_SQL = /FROM\s+"(?<table>[^"]+)"/
      attr_accessor :active_record_query_tracker, :subscription

      def initialize
        reset_query_count
      end

      # This assums that in the same location of the code it will always be the same sql query
      def reset_query_count
        @active_record_query_tracker = Hash.new do |hash, key|
          hash[key] = { count: 0, location: Hash.new do |loc_hash, loc_key|
                                              loc_hash[loc_key] = { count: 0, sql: nil, duration: 0, cached_query_count: 0 }
                                            end }
        end
      end

      def subscribe
        return unless subscription.nil?

        @subscription = ActiveSupport::Notifications.subscribe('sql.active_record') do |_a, start, finish, _d, payload|
          caller_from_sql = caller
          sql = payload[:sql]
          cached = payload[:cached] ? 1 : 0
          match = sql.match(REGEX_TABLE_SQL)
          if match.present? && match[:table]
            actual_location = Rails.backtrace_cleaner.clean(caller_from_sql).first
            active_record_query_tracker[match[:table]][:count] += 1
            active_record_query_tracker[match[:table]][:location][actual_location][:duration] += (finish - start) * 1000
            active_record_query_tracker[match[:table]][:location][actual_location][:count] += 1
            active_record_query_tracker[match[:table]][:location][actual_location][:sql] = sql
            active_record_query_tracker[match[:table]][:location][actual_location][:cached_query_count] += cached
          end
        end
      end

      def unsubscribe
        ActiveSupport::Notifications.unsubscribe(@subscription)
        @subscription = nil
      end
    end
  end
end
