module ActiveRecordQueryCount
  module Compare
    class Comparator
      attr_accessor :results, :scripts_loaded

      def initialize
        @results = {}
        @scripts_loaded = 0
        @max_objects_in_memory = {}
      end

      def code(name)
        @scripts_loaded += 1

        ActiveRecordQueryCount.start_with_block(printer: :none) do
          yield
          @results[name] = ActiveRecordQueryCount.tracker.active_record_query_tracker.dup
          @max_objects_in_memory[name] = ActiveRecordQueryCount.tracker.max_objects_in_memory
          # TODO: how can i reset requestlocals if defined
          GC.start
        end
      end

      def compare!
        raise 'Exactly two code blocks are required' if @scripts_loaded != 2

        ActiveRecordQueryCount::Printer::HtmlCompare.new(data_1: results.slice(results.keys[0]),
                                                         data_2: results.slice(results.keys[1]),
                                                         max_objects_in_memory_1: @max_objects_in_memory.values[0],
                                                         max_objects_in_memory_2: @max_objects_in_memory.values[1],
                                                         ).print
      end
    end

    def self.compare
      comparator = Comparator.new
      yield(comparator)
    end
  end
end
