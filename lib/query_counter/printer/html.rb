require 'erb'
require 'tempfile'
require 'launchy'
require 'pry-byebug'
require 'json'

module QueryCounter
  module Printer
    class Html < Base
      def initialize mode: :single, data_1:, data_2: nil
        super()
        @mode = mode
        @template_path = @mode == :compare ? File.join(__dir__, 'templates', 'comparing.html.erb') : File.join(__dir__, 'templates', 'template.html.erb')
        @css_path = File.join(__dir__, 'templates', 'style.css')
        @js_path = File.join(__dir__, 'templates', 'chart.js.erb')
        @data_1 = data_1
        @data_2 = data_2
      end

      def print
        data = filter_data(@data_1)
        # used by binding on erb templates
        total_query_count = data.values.sum { |v| v[:count] }
        chart_data = generate_chart_data(data)
        html_dest = generate_html(binding)
        open_file(html_dest)
      end

      
      def print_compare
        data_1 = filter_data(@data_1)
        data_2 = filter_data(@data_2)
        # used by binding on erb templates
        total_query_count = data_1.values.sum { |v| v[:count] }
        chart_data = generate_chart_data_compare(data_1, data_2)
        html_dest = generate_html(binding)
        open_file(html_dest)
      end
      
      private 
        def generate_chart_data(data)
          chart_data = { labels: [], data: [], locations: {} }
          data.each do |table, info|
            chart_data[:labels] << table
            chart_data[:data] << info[:count]
            chart_data[:locations][table] = info[:location].map { |loc, detail| { location: loc, count: detail[:count] } }
          end
          chart_data
        end

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

        def open_file html_dest
          if ENV['WSL_DISTRIBUTION']
            Launchy.open("file://wsl%24/#{ENV["WSL_DISTRIBUTION"]}#{html_dest}")
          else
            Launchy.open(html_dest)
          end
        end

        def generate_html binding
          template = ERB.new(File.read(@template_path))
          js_template = ERB.new(File.read(@js_path))
          js_content = js_template.result(binding)
          html_content = template.result(binding)

          temp_dir = Dir.mktmpdir
          css_dest = File.join(temp_dir, 'style.css')
          js_dest = File.join(temp_dir, 'script.js')
          html_dest = File.join(temp_dir, 'query_counter_report.html')

          FileUtils.cp(@css_path, css_dest)
          File.write(js_dest, js_content)
          File.write(html_dest, html_content)
          html_dest
        end
    end
  end
end