# frozen_string_literal: true

require 'test_helper'

class TestQueryCounter < Minitest::Test
  context 'listen to changes in tracker' do
    setup do
      @tracker = QueryCounter.tracker
      @expected_sql = 'SELECT "test_models".* FROM "test_models" ORDER BY "test_models"."id" DESC LIMIT ?'
    end

    should 'generate hash with count, locations and sql of the queries made' do
      QueryCounter.start_recording
      TestModel.create(name: 'test')
      TestModel.last
      TestModel.last
      assert_equal 2, @tracker.query_count['test_models'][:count]
      locations = @tracker.query_count['test_models'][:location]
      path_1 = locations.keys.find { |path| path['query_counter/test/query_counter_test.rb:16'] }
      path_2 = locations.keys.find { |path| path['query_counter/test/query_counter_test.rb:17'] }
      assert_equal 1, locations[path_1][:count]
      assert_equal @expected_sql, locations[path_1][:sql]
      assert_equal 1, locations[path_2][:count]
      assert_equal @expected_sql, locations[path_2][:sql]
      QueryCounter.end_recording
    end
  end
end
