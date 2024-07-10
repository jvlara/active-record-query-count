require 'erb'
require 'tempfile'
require 'launchy'
require 'pry-byebug'
require 'json'

module ActiveRecordQueryTracker
  module Printer
    class Html < Base
      attr_accessor :data

      def initialize data:
        @template_path = File.join(__dir__, 'templates', 'template.html.erb')
        @base_query_counter_path = File.join(__dir__, 'templates', 'template_base_query_counter.html.erb')
        @inject_template_path = File.join(__dir__, 'templates', 'template_for_inject.html.erb')
        @css_path = File.join(__dir__, 'templates', 'style.css')
        # este no falla, quizá pueda poner lo mismo aquí con chart.js y así no hacer lo del nonce y csp
        @js_path = File.join(__dir__, 'templates', 'bar_chart.js')
        @data = data
      end

      def chart_data
        @chart_data ||= generate_chart_data(data)
      end

      # maybe this should not be filtered
      def total_query_count
        @total_query_count ||= data.values.sum { |v| v[:count] }
      end

      def inject_in_html
        ERB.new(File.read(@inject_template_path)).result(binding)
      end

      def render_query_counter_base_div
        ERB.new(File.read(@base_query_counter_path)).result(binding)
      end

      def print
        html_dest = generate_html(binding)
        open_file(html_dest)
      end

      private

      def generate_chart_data(data)
        chart_data = { labels: [], data: [], locations: {} }
        data.each do |table, info|
          chart_data[:labels] << table
          chart_data[:data] << info[:count]
          chart_data[:locations][table] = info[:location].map do |loc, detail|
            { location: loc, count: detail[:count] }
          end
        end
        chart_data
      end

      def generate_html binding
        template = ERB.new(File.read(@template_path))
        html_content = template.result(binding)
        temp_dir = Dir.mktmpdir
        html_dest = File.join(temp_dir, 'query_counter_report.html')
        File.write(html_dest, html_content)
        html_dest
      end
    end
  end
end
