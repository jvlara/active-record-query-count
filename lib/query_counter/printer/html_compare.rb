require 'erb'
require 'tempfile'
require 'launchy'
require 'pry-byebug'
require 'json'

module QueryCounter
  module Printer
    class HtmlCompare < Base
      def initialize data_1:, data_2:
        super()
        @template_path = File.join(__dir__, 'templates', 'comparing.html.erb')
        @css_path = File.join(__dir__, 'templates', 'style.css')
        @js_path = File.join(__dir__, 'templates', 'bar_chart.js')
        @data_1 = data_1
        @data_2 = data_2
      end
      
      def print
        data_1 = filter_data(@data_1)
        data_2 = filter_data(@data_2)
        tables = data_1.keys | data_2.keys
        # used by binding on erb templates
        total_query_count = data_1.values.sum { |v| v[:count] }
        chart_data = generate_chart_data_compare(data_1, data_2)
        html_dest = generate_html(binding)
        open_file(html_dest)
      end
    
      private 

        def generate_chart_data_compare(data1, data2)
          labels = (data1.keys | data2.keys).sort
          chart_data = { labels: [], data1: [], data2: [], locations: {} }
          labels.each do |label|
            chart_data[:labels] << label
            chart_data[:data1] << (data1[label] ? data1[label][:count] : 0)
            chart_data[:data2] << (data2[label] ? data2[label][:count] : 0)
            chart_data[:locations][label] = (data1[label] ? data1[label][:location] : {}).merge(data2[label] ? data2[label][:location] : {})
          end
          chart_data
        end

        def generate_html binding, raw_html: false
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