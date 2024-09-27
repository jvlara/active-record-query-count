require 'colorize'

module ActiveRecordQueryCount
  module Printer
    class Console < Base
      def initialize data:
        super()
        @data = data
      end

      def print
        data = filter_data(@data)
        puts '[ActiveRecordQueryCount] Query count per table:'.colorize(:blue)
        puts "Total query count: #{data.values.sum { |v| v[:count] }}\n\n"
        puts "All tables with less than #{Configuration.ignore_table_count} queries are ignored. \n\n"
        puts "For each table, the top #{Configuration.max_locations_per_table} locations with the most queries will be shown.\n\n"
        data.each do |category, info|
          puts "Table #{category.colorize(:cyan)}"
          puts "  Total query count: #{info[:count].to_s.colorize(:blue)}"
          puts '  Locations where the table was called:'
          info[:location].each do |loc, details|
            puts "    - File location: #{loc}"
            puts "        Query count: #{details[:count].to_s.colorize(:blue)}"
            puts "        Total Duration(ms): #{details[:duration]}"
          end
          puts
        end
      end
    end
  end
end
