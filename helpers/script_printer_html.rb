require_relative '../lib/query_tracker'
require 'pry-byebug'

data = File.read('helpers/con problemas.yaml')
data = YAML.safe_load(data, permitted_classes: [Proc, Symbol])
QueryTracker.start_with_block(printer: :html) do
  QueryTracker.tracker.instance_variable_set :@query_tracker, data
end

# temp_dir = Dir.mktmpdir
# html_dest = File.join(temp_dir, 'query_counter_report.html')
# File.write(html_dest, x)
# Launchy.open("file://wsl%24/#{ENV["WSL_DISTRIBUTION"]}#{html_dest}")
