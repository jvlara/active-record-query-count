module QueryCounter
  module Printer
    class Base
      def filter_data data
        data = data.select { |_, v| v[:count] >= Configuration.ignore_table_count }
        data = data.sort_by { |_, v| -v[:count] }.each do |_category, info|
          info[:location] = info[:location].sort_by do |_, detail|
            -detail[:count]
          end.first(Configuration.max_locations_per_table).to_h
        end
        data.to_h
      end

      def open_file html_dest
        if ENV['WSL_DISTRIBUTION']
          Launchy.open("file://wsl%24/#{ENV['WSL_DISTRIBUTION']}#{html_dest}")
        else
          Launchy.open(html_dest)
        end
      end

      # this js is not used as erb, it could be changed
      def js_content
        File.read(@js_path)
      end

      # this js is not used as erb, it could be changed
      def css_content
        File.read(@css_path)
      end
    end
  end
end
