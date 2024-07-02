module QueryCounter
  class Tracker
    REGEX_TABLE_SQL = /FROM\s+"(?<table>[^"]+)"/
    attr_accessor :query_count, :subscription

    def initialize
      reset_query_count
    end

    # This assums that in the same location of the code it will always be the same sql query
    def reset_query_count
      @query_count = Hash.new { |hash, key| hash[key] = { count: 0, location: Hash.new { |loc_hash, loc_key| loc_hash[loc_key] = { count: 0, sql: nil } } } }
    end

    def subscribe
      return unless subscription.nil?
      @subscription = ActiveSupport::Notifications.subscribe("sql.active_record") do |a, b, c, d, payload|
        caller_from_sql = caller
        sql = payload[:sql]
        match = sql.match(REGEX_TABLE_SQL)
        if match.present? && match[:table]
          actual_location = Rails.backtrace_cleaner.clean(caller_from_sql).first
          query_count[match[:table]][:count] += 1
          query_count[match[:table]][:location][actual_location][:count] += 1
          query_count[match[:table]][:location][actual_location][:sql] = sql
        end
      end
    end

    def unsubscribe
      ActiveSupport::Notifications.unsubscribe(@subscription)
      @subscription = nil
    end
  end
end