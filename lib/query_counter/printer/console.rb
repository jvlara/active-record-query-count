module QueryCounter
  module Printer
    class Console < Base
      def self.print(raw_data)
        data = data(raw_data)
        puts "[QueryCounter] Query count per table:".colorize(:blue)
        puts "Total query count: #{data.values.sum { |v| v[:count] }}\n\n"
        puts "All tables with less than #{Configuration.ignore_table_count} queries are ignored. \n\n"
        puts "For each table, the top #{Configuration.max_locations_per_table} locations with the most queries will be shown.\n\n"
        data.each do |category, info|
          puts "Table #{category.colorize(:cyan)}"
          puts "  Total query count: #{info[:count].to_s.colorize(:blue)}"
          puts "  Locations where the table was called:"
          locations.each do |loc, count|
            location_display = loc.nil? ? 'None' : loc
            puts "    - File location: #{location_display}"
            puts "        Query count: #{count.to_s.colorize(:blue)}"
          end
          puts
        end
      end
    end
  end
end
