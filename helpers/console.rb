require_relative '../lib/query_counter'
require 'pry-byebug'

data = File.read('helpers/example_data.yaml')
data = YAML.safe_load(data, permitted_classes: [Proc, Symbol])
QueryCounter.start_with_block(printer: :console) do
  QueryCounter.tracker.instance_variable_set :@query_count, data
end