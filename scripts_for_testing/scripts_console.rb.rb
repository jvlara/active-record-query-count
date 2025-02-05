require 'pry-byebug'
require 'active-record-query-count'

data = File.read('scripts_for_testing/example_script_unoptimize.yaml')
data = YAML.safe_load(data, permitted_classes: [Proc, Symbol])
ActiveRecordQueryCount.start_with_block(printer: :console) do
  ActiveRecordQueryCount.tracker.instance_variable_set :@active_record_query_tracker, data
end
