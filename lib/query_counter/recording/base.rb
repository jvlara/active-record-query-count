module QueryCounter
  module Recording
    module Base
      def start_with_block(printer: :console)
        if block_given?
          start_recording
          yield
          end_recording(printer: printer)
        else
          raise "Block not given"
        end
      end

      def start_recording
        tracker.reset_query_count
        tracker.subscribe
      end

      def end_recording(printer: :console)
        tracker.unsubscribe
        case printer
        when :html
          Printer::Html.print(tracker.query_count)
        else
          Printer::Console.print(tracker.query_count)
        end
      end
    end
  end
end