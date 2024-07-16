# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require_relative 'test/test_helper'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test
