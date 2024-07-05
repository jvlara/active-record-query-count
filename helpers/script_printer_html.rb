require_relative '../lib/query_counter'
require 'pry-byebug'

data = File.read('helpers/con problemas.yaml')
data = YAML.safe_load(data, permitted_classes: [Proc, Symbol])
# QueryCounter.start_with_block(printer: :html) do
#   QueryCounter.tracker.instance_variable_set :@query_count, data
# end

x = QueryCounter::Printer::HtmlCompare.new(data_1: data, data_2: data).print
binding.pry
y = 1
# temp_dir = Dir.mktmpdir
# html_dest = File.join(temp_dir, 'query_counter_report.html')
# File.write(html_dest, x)
# Launchy.open("file://wsl%24/#{ENV["WSL_DISTRIBUTION"]}#{html_dest}")
