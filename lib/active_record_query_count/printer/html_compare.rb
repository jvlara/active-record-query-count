require 'erb'
require 'tempfile'
require 'launchy'
require 'pry-byebug'
require 'json'

module ActiveRecordQueryCount
  module Printer
    class HtmlCompare < Base
      def initialize data_1:, data_2:, max_objects_in_memory_1: 0, max_objects_in_memory_2: 0
        # make the first key tables and outside some more variables like memory, max object in memory
        super()
        @script_1_name = data_1.keys.first
        @script_2_name = data_2.keys.first
        @data_1 = data_1[@script_1_name]
        @data_2 = data_2[@script_2_name]
        @max_objects_in_memory_1 = max_objects_in_memory_1
        @max_objects_in_memory_2 = max_objects_in_memory_2
      end

      # TODO: the sql on the data_1 and data_2 of the same location could be different
      #       in the html we only show the sql of the first script
      #       It maybe better to remove the sql from the table in this case
      def print
        # used by binding on erb templates
        data_1 = sort_data(@data_1)
        data_2 = sort_data(@data_2)
        tables = data_1.keys | data_2.keys
        total_query_count_1 = data_1.values.sum { |v| v[:count] }
        total_instantiation_1 = data_1.values.sum { |v| v[:instantiation_count].nil? ? 0 : v[:instantiation_count] }
        max_objects_in_memory_1 = @max_objects_in_memory_1
        total_query_count_2 = data_2.values.sum { |v| v[:count] }
        total_instantiation_2 = data_2.values.sum { |v| v[:instantiation_count].nil? ? 0 : v[:instantiation_count] }
        max_objects_in_memory_2 = @max_objects_in_memory_2
        chart_data = generate_chart_data_compare(data_1, data_2)
        # end
        html_dest = generate_html(binding)
        open_file(html_dest)
      end

      private

      def generate_chart_data_compare(data_1, data_2)
        labels = (data_1.keys | data_2.keys).sort
        chart_data = { labels: [], data_1: {}, data_2: {}, locations: {} }
        chart_data[:data_1][:name] = @script_1_name
        chart_data[:data_2][:name] = @script_2_name
        chart_data[:data_1][:data] = []
        chart_data[:data_2][:data] = []
        labels.each do |label|
          chart_data[:labels] << label
          chart_data[:data_1][:data] << (data_1[label] ? data_1[label][:count] : 0)
          chart_data[:data_2][:data] << (data_2[label] ? data_2[label][:count] : 0)
          chart_data[:locations][label] =
            (data_1[label] ? data_1[label][:location] : {}).merge(data_2[label] ? data_2[label][:location] : {})
        end
        chart_data
      end

      def generate_html binding
        template = ERB.new(template_comparing_content)
        html_content = template.result(binding)

        temp_dir = Dir.mktmpdir
        html_dest = File.join(temp_dir, 'query_counter_report.html')
        File.write(html_dest, html_content)
        html_dest
      end
    end
  end
end
