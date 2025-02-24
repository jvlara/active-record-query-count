# usage: bundle exec ruby scripts_for_testing/script_printer_html.rb

require 'pry-byebug'
require 'active-record-query-count'

data = File.read('scripts_for_testing/example_script_unoptimize.yaml')
data = YAML.safe_load(data, permitted_classes: [Proc, Symbol])
ActiveRecordQueryCount.start_with_block(printer: :html) do
  ActiveRecordQueryCount.tracker.instance_variable_set :@active_record_query_tracker, data
end
