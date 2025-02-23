require 'erb'

module ActiveRecordQueryCount
  module Printer
    class Html < Base
      attr_accessor :data

      def initialize data:
        @data = data
      end

      def chart_data
        @chart_data ||= generate_chart_js_data(data)
      end

      def total_query_count
        @total_query_count ||= data.values.sum { |v| v[:count] }
      end

      def total_duration_time
        @total_duration_time ||= data.sum do |_, info|
          info[:location].sum do |_, detail|
            detail[:duration]
          end
        end.truncate(2)
      end

      def inject_in_html
        ERB.new(inject_template_content).result(binding)
      end

      def render_query_counter_base_div
        ERB.new(base_query_counter_content).result(binding)
      end

      def print
        html_dest = generate_html(binding)
        open_file(html_dest)
      end

      private

      def generate_chart_js_data(data)
        chart_data = { labels: [], data: [], locations: {} }
        data.each do |table, info|
          chart_data[:labels] << table
          chart_data[:data] << info[:count]
          chart_data[:locations][table] = info[:location].map do |loc, detail|
            { location: loc, count: detail[:count], duration: detail[:duration], cached_query_count: detail[:cached_query_count] }
          end
        end
        chart_data
      end

      def generate_html binding
        template = ERB.new(template_content)
        html_content = template.result(binding)
        temp_dir = Dir.mktmpdir
        html_dest = File.join(temp_dir, 'query_counter_report.html')
        File.write(html_dest, html_content)
        html_dest
      end
    end
  end
end
