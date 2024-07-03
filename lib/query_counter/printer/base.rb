module QueryCounter
  module Printer
    class Base
      def filter_data data
        data = data.select { |_, v| v[:count] >= Configuration.ignore_table_count }
        data = data.sort_by { |_, v| -v[:count] }.each do |category, info|
          info[:location] = info[:location].sort_by { |_, detail| -detail[:count] }.first(Configuration.max_locations_per_table).to_h
        end
        data.to_h
      end
    end
  end
end