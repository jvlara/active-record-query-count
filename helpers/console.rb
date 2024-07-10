require_relative '../lib/query_tracker'
require 'pry-byebug'

data = File.read('helpers/example_data.yaml')
data = YAML.safe_load(data, permitted_classes: [Proc, Symbol])
QueryTracker.start_with_block(printer: :console) do
  QueryTracker.tracker.instance_variable_set :@query_tracker, data
end
