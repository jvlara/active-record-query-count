require 'erb'
require 'tempfile'
require 'launchy'
require 'pry-byebug'
require 'json'

module QueryCounter
  module Printer
    class Html < Base
      TEMPLATE_PATH = File.join(__dir__, 'templates', 'template.html.erb')
      CSS_PATH = File.join(__dir__, 'templates', 'style.css')
      JS_PATH = File.join(__dir__, 'templates', 'chart.js.erb')

      def self.print(raw_data)
        data = data(raw_data)
        total_query_count = data.values.sum { |v| v[:count] }
        chart_data = generate_chart_data(data)
        template = ERB.new(File.read(TEMPLATE_PATH))
        js_template = ERB.new(File.read(JS_PATH))
        js_content = js_template.result(binding)
        html_content = template.result(binding)

        temp_dir = Dir.mktmpdir
        css_dest = File.join(temp_dir, 'style.css')
        js_dest = File.join(temp_dir, 'script.js')
        html_dest = File.join(temp_dir, 'query_counter_report.html')

        FileUtils.cp(CSS_PATH, css_dest)
        File.write(js_dest, js_content)
        File.write(html_dest, html_content)
        if ENV['WSL_DISTRIBUTION']
          Launchy.open("file://wsl%24/#{ENV["WSL_DISTRIBUTION"]}#{html_dest}")
        else
          Launchy.open(html_dest)
        end
      end

      def self.generate_chart_data(data)
        chart_data = { labels: [], data: [], locations: {} }
        data.each do |table, info|
          chart_data[:labels] << table
          chart_data[:data] << info[:count]
          chart_data[:locations][table] = info[:location].map { |loc, detail| { location: loc, count: detail[:count] } }
        end
        chart_data
      end
    end
  end
end