require_relative '../lib/active_record_query_tracker'
require 'pry-byebug'

data = File.read('helpers/example_data.yaml')
data = YAML.safe_load(data, permitted_classes: [Proc, Symbol])
ActiveRecordQueryTracker.start_with_block(printer: :console) do
  ActiveRecordQueryTracker.tracker.instance_variable_set :@active_record_query_tracker, data
end
