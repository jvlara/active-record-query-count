module ActiveRecordQueryTracker
  module Compare
    class Comparator
      attr_accessor :results, :scripts_loaded

      def initialize
        @results = {}
        @scripts_loaded = 0
      end

      def code(name)
        @scripts_loaded += 1

        ActiveRecordQueryTracker.start_with_block(printer: :none) do
          yield
          @results[name] = ActiveRecordQueryTracker.tracker.active_record_query_tracker.dup
        end
      end

      def compare!
        raise 'Exactly two code blocks are required' if @scripts_loaded != 2

        ActiveRecordQueryTracker::Printer::HtmlCompare.new(data_1: results.slice(results.keys[0]),
                                               data_2: results.slice(results.keys[1])).print
      end
    end

    def self.compare
      comparator = Comparator.new
      yield(comparator)
    end
  end
end
