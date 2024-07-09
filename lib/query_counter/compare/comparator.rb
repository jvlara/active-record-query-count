module QueryCounter
  module Compare
    class Comparator
      attr_accessor :results
      attr_accessor :scripts_loaded

      def initialize
        @results = {}
        @scripts_loaded = 0
      end

      def code(name)
        @scripts_loaded += 1

        QueryCounter.start_with_block(printer: :none) do
          yield
          @results[name] = QueryCounter.tracker.query_count.dup
        end
      end

      def compare!
        raise "Exactly two code blocks are required" if @scripts_loaded != 2
        QueryCounter::Printer::HtmlCompare.new(data_1: results.slice(results.keys[0]), data_2: results.slice(results.keys[1])).print
      end
    end

    def self.compare
      comparator = Comparator.new
      yield(comparator)
    end
  end
end