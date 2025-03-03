require 'test_helper'

class PrinterTest < Minitest::Test
  context 'printing methods' do
    setup do
      ActiveRecordQueryCount::Configuration.max_locations_per_table = 4
      ActiveRecordQueryCount::Configuration.ignore_table_count = 1
      @data = { 'users' =>
      { count: 2,
        location: { 'location_1' => { count: 2,
                                      cached_query_count: 0,
                                      duration: 2.5,
                                      sql: 'SELECT "users".* FROM "users" WHERE "users"."email" = $1 LIMIT $2' },
                    'location_2' => { count: 2,
                                      cached_query_count: 1,
                                      duration: 2.5,
                                      sql: 'SELECT "users".* FROM "users" WHERE "users"."email" = $1 LIMIT $2' } } } }
    end

    should 'print html output without errors' do
      Launchy.expects(:open).with(anything).once
      ActiveRecordQueryCount::Printer::Html.new(data: @data).print
    end

    should 'print html compare output without errors' do
      Launchy.expects(:open).with(anything).once
      ActiveRecordQueryCount::Printer::HtmlCompare.new(data_1: { 'script1': @data }, data_2: { 'script2': @data }).print
    end

    should 'print console output without errors' do
      ActiveRecordQueryCount::Printer::Console.new(data: @data).print
    end

    # test ignore_table_count #
    should 'hide the message in html when ignore_table_count is 1 or less' do
      threshold = 1
      ActiveRecordQueryCount::Configuration.ignore_table_count = threshold
      message = "Only tables with #{threshold} or more queries will be displayed."
      assert_html_message_presence(@data, message, false)
    end

    should 'display the message in html when ignore_table_count is greater than 1' do
      threshold = 2
      ActiveRecordQueryCount::Configuration.ignore_table_count = threshold
      message = "Only tables with #{threshold} or more queries will be displayed."
      assert_html_message_presence(@data, message, true)
    end

    should 'hide display the message in console when ignore_table_count is 1 or less' do
      threshold = 1
      ActiveRecordQueryCount::Configuration.ignore_table_count = threshold
      message = "All tables with less than #{threshold} queries are ignored."
      assert_console_message_presence(@data, message, false)
    end

    should 'display the message in console when ignore_table_count is greater than 1' do
      threshold = 2
      ActiveRecordQueryCount::Configuration.ignore_table_count = threshold
      message = "All tables with less than #{threshold} queries are ignored."
      assert_console_message_presence(@data, message, true)
    end

    # test max_locations_per_table #
    should 'hide the message in html when max_locations_per_table is 0' do
      threshold = 0
      ActiveRecordQueryCount::Configuration.max_locations_per_table = threshold
      message = "The top #{threshold} locations with the highest occurrences will be shown for each table."
      assert_html_message_presence(@data, message, false)
    end

    should 'display the message in html when max_locations_per_table is greater than 0' do
      threshold = 1
      ActiveRecordQueryCount::Configuration.max_locations_per_table = threshold
      message = "The top #{threshold} locations with the highest occurrences will be shown for each table."
      assert_html_message_presence(@data, message, true)
    end

    should 'not display the message in console when max_locations_per_table is 0' do
      threshold = 0
      ActiveRecordQueryCount::Configuration.max_locations_per_table = threshold
      message = "For each table, the top #{threshold} locations with the most queries will be shown."
      assert_console_message_presence(@data, message, false)
    end

    should 'display the message in console when max_locations_per_table is greater than 0' do
      threshold = 1
      ActiveRecordQueryCount::Configuration.max_locations_per_table = threshold
      message = "For each table, the top #{threshold} locations with the most queries will be shown."
      assert_console_message_presence(@data, message, true)
    end

    should 'display all file in html when max_locations_per_table is 0' do
      threshold = 0
      ActiveRecordQueryCount::Configuration.max_locations_per_table = threshold
      occurrences = query_counter_report_div(@data).scan('location_').count
      # Each location appears twice in the HTML, once inside the <table id="queryTable"> and once inside the <script>.
      assert_equal(4, occurrences)
    end

    should 'display all file location in console when max_locations_per_table is 0' do
      threshold = 0
      ActiveRecordQueryCount::Configuration.max_locations_per_table = threshold
      output = capture_stdout do
        ActiveRecordQueryCount::Printer::Console.new(data: @data).print
      end
      occurrences = output.scan('File location: location_').count
      assert_equal(2, occurrences)
    end
  end
end
