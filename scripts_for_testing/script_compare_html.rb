require 'active-record-query-count'
require 'pry-byebug'

data_1 = File.read('scripts_for_testing/example_script_unoptimize.yaml')
data_2 = File.read('scripts_for_testing/example_script_optimize.yaml')
data_1 = YAML.safe_load(data_1, permitted_classes: [Proc, Symbol])
data_2 = YAML.safe_load(data_2, permitted_classes: [Proc, Symbol])
ActiveRecordQueryCount.compare do |comparing|
  comparing.code('First code block') do
    ActiveRecordQueryCount.tracker.instance_variable_set :@active_record_query_tracker, data_1
  end
  comparing.code('Second code block') do
    ActiveRecordQueryCount.tracker.instance_variable_set :@active_record_query_tracker, data_2
  end
  comparing.compare!
end
