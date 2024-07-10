# frozen_string_literal: true

require_relative 'lib/active_record_query_tracker/version'

Gem::Specification.new do |spec|
  spec.name = 'active_record_query_tracker'
  spec.version = ActiveRecordQueryTracker::VERSION
  spec.authors = ['Jose Lara']
  spec.email = ['jvlara@uc.cl']

  spec.summary = 'Display an overview of quantity of queries and their origin in Rails applications.'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.2'
  spec.homepage = 'https://github.com/jvlara/active_record_query_tracker'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |file|
      file.start_with?(*%w[.git Gemfile Rakefile
                           active_record_query_tracker- active_record_query_tracker.gemspec test helpers .rubocop.yml .ruby-version CHANGELOG CODE_OF_CONDUCT.md
                           CONTRIBUTING.md LICENSE])
    end
  end
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_runtime_dependency 'activesupport', '~> 6.0'
  spec.add_runtime_dependency 'colorize', '~> 1.1'
  spec.add_runtime_dependency 'launchy', '~> 3.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.16.5'

  spec.add_development_dependency 'activerecord', '~> 6.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'ruby-lsp'
  spec.add_development_dependency 'shoulda-context'
  spec.add_development_dependency 'shoulda-matchers', '~> 6.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
end
