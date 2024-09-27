# frozen_string_literal: true

require 'test_helper'

class TestQueryTracker < Minitest::Test
  context 'listen to changes in tracker' do
    setup do
      @tracker = ActiveRecordQueryCount.tracker
      @expected_sql = 'SELECT "test_models".* FROM "test_models" ORDER BY "test_models"."id" DESC LIMIT ?'
    end

    should 'generate hash with count, locations and sql of the queries made' do
      ActiveRecordQueryCount.start_recording
      TestModel.create(name: 'test')
      TestModel.last
      TestModel.last
      assert_equal 2, @tracker.active_record_query_tracker['test_models'][:count]
      locations = @tracker.active_record_query_tracker['test_models'][:location]
      path_1 = locations.keys.find { |path| path['test/query_tracker_test.rb:15'] }
      path_2 = locations.keys.find { |path| path['test/query_tracker_test.rb:16'] }
      assert_equal 1, locations[path_1][:count]
      assert locations[path_1][:duration].positive?
      assert_equal @expected_sql, locations[path_1][:sql]
      assert_equal 1, locations[path_2][:count]
      assert locations[path_2][:duration].positive?
      assert_equal @expected_sql, locations[path_2][:sql]
      ActiveRecordQueryCount.end_recording
    end
  end
end
