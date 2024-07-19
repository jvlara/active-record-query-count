require 'objspace'
module ActiveRecordQueryCount
  class Tracker
    REGEX_TABLE_SQL = /FROM\s+"(?<table>[^"]+)"/
    attr_accessor :active_record_query_tracker, :subscription_query, :subscription_ar, :tracking_thread, :max_objects_in_memory

    def initialize
      @max_objects_in_memory = 0
      reset_query_count
    end

    # This assums that in the same location of the code it will always be the same sql query
    def reset_query_count
      @active_record_query_tracker = Hash.new do |hash, key|
        hash[key] = { count: 0, location: Hash.new do |loc_hash, loc_key|
                                            loc_hash[loc_key] = { count: 0, sql: nil }
                                          end,
                                          instantiation_count: 0,
                                          # ids_object_count: Hash.new(0)
                                        }
      end
    end

    def subscribe
      return unless subscription_query.nil? || subscription_ar.nil?

      @subscription_query = ActiveSupport::Notifications.subscribe('sql.active_record') do |_a, _b, _c, _d, payload|
        caller_from_sql = caller
        sql = payload[:sql]
        match = sql.match(REGEX_TABLE_SQL)
        if match.present? && match[:table]
          actual_location = Rails.backtrace_cleaner.clean(caller_from_sql).first
          active_record_query_tracker[match[:table]][:count] += 1
          active_record_query_tracker[match[:table]][:location][actual_location][:count] += 1
          active_record_query_tracker[match[:table]][:location][actual_location][:sql] = sql
        end
      end
      @subscription_ar = ActiveSupport::Notifications.subscribe('instantiation.active_record') do |a, b, c, id, payload|
        table_name = payload[:class_name].constantize.table_name
        active_record_query_tracker[table_name][:instantiation_count] += payload[:record_count]
        # TODO: instantiation intrumentation does not have the ids for the records, check how can we get them and count duplicates
        # active_record_query_tracker[table_name][:ids_object_count][id] += 1
      end
      @tracking_thread = Thread.new do
        loop do
          track_max_objects
          sleep 0.1 # Adjust the interval as needed
        end
      end
    end

    def unsubscribe
      ActiveSupport::Notifications.unsubscribe(@subscription_query)
      ActiveSupport::Notifications.unsubscribe(@subscription_ar)
      @subscription_query = nil
      @subscription_ar = nil
      @tracking_thread.kill
    end

    # Method to check the current number of objects and update the counter
    def track_max_objects
      current_objects = ObjectSpace.each_object.count
      self.max_objects_in_memory = current_objects if current_objects > self.max_objects_in_memory
    end
  end
end
