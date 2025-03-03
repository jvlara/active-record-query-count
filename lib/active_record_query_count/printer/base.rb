require 'json'
module ActiveRecordQueryCount
  module Printer
    class Base
      parent_dir = File.expand_path('../../../', __dir__)
      TEMPLATE_PATH = File.join(parent_dir, 'assets', 'template.html.erb')
      TEMPLATE_COMPARING_PATH = File.join(parent_dir, 'assets', 'comparing.html.erb')
      CSS_PATH = File.join(parent_dir, 'assets', 'style.css')
      JS_PATH = File.join(parent_dir, 'assets', 'bar_chart.js')
      CHART_JS_CONTENT = File.join(parent_dir, 'assets', 'chart.min.js')
      BASE_QUERY_COUNTER_PATH = File.join(parent_dir, 'assets', 'template_base_query_counter.html.erb')
      INJECT_TEMPLATE_PATH = File.join(parent_dir, 'assets', 'template_for_inject.html.erb')

      def filter_data data
        data.each_value do |info|
          info[:location].each_value do |detail|
            detail[:duration] = detail[:duration].truncate(2)
          end
        end
        data = data.select { |_, v| v[:count] >= Configuration.ignore_table_count }
        data = data.sort_by { |_, v| -v[:count] }.each do |_category, info|
          next if Configuration.max_locations_per_table.zero?

          info[:location] = info[:location].sort_by do |_, detail|
            -detail[:count]
          end.first(Configuration.max_locations_per_table).to_h
        end
        data.to_h
      end

      def sort_data data
        data = data.sort_by { |_, v| -v[:count] }.each do |_category, info|
          info[:location] = info[:location].sort_by do |_, detail|
            -detail[:count]
          end.to_h
        end
        data.to_h
      end

      def open_file html_dest
        require 'launchy'
        if ENV['WSL_DISTRIBUTION']
          Launchy.open("file://wsl%24/#{ENV['WSL_DISTRIBUTION']}#{html_dest}")
        else
          Launchy.open(html_dest)
        end
      end

      def js_content
        File.read(JS_PATH)
      end

      def chart_js_content
        File.read(CHART_JS_CONTENT)
      end

      def css_content
        File.read(CSS_PATH)
      end

      def template_content
        File.read(TEMPLATE_PATH)
      end

      def template_comparing_content
        File.read(TEMPLATE_COMPARING_PATH)
      end

      def base_query_counter_content
        File.read(BASE_QUERY_COUNTER_PATH)
      end

      def inject_template_content
        File.read(INJECT_TEMPLATE_PATH)
      end
    end
  end
end
