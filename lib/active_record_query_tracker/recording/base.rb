module ActiveRecordQueryTracker
  module Recording
    module Base
      def start_with_block(printer: :console)
        raise 'Block not given' unless block_given?

        start_recording
        yield
        end_recording(printer:)
      end

      def start_recording
        tracker.reset_query_count
        tracker.subscribe
      end

      def end_recording(printer: :console)
        tracker.unsubscribe
        case printer
        when :html
          Printer::Html.new(data: tracker.active_record_query_tracker).print
        when :console
          Printer::Console.new(data: tracker.active_record_query_tracker).print
        end
      end
    end
  end
end
