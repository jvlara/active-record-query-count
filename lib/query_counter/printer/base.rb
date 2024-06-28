module QueryCounter
  module Printer
    class Base
      def self.print(data)
        raise NotImplementedError, "Subclasses must implement the `print` method"
      end

      def self.data data
        data = data.select { |_, v| v[:count] >= Configuration.ignore_table_count }
        data = data.sort_by { |_, v| -v[:count] }.each do |category, info|
          info[:location] = info[:location].sort_by { |_, v| -v }.first(Configuration.max_locations_per_table).to_h
        end
        data.to_h
      end
    end
  end
end