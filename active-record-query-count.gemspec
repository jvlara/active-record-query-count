# frozen_string_literal: true

require_relative 'lib/active_record_query_count/version'

Gem::Specification.new do |spec|
  spec.name = 'active-record-query-count'
  spec.version = ActiveRecordQueryCount::VERSION
  spec.authors = ['Jose Lara']
  spec.email = ['jvlara@uc.cl']

  spec.summary = 'Display an overview of the quantity of queries being made and their origins in a block of code in Rails applications.'
  spec.license = 'MIT'
  spec.required_ruby_version = ['>= 3.0', '< 4.0']
  spec.homepage = 'https://github.com/jvlara/active-record-query-count'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |file|
      file.start_with?(*%w[.git Gemfile Rakefile
                           active-record-query-count- active-record-query-count.gemspec test helpers .rubocop.yml .ruby-version CHANGELOG CODE_OF_CONDUCT.md
                           CONTRIBUTING.md LICENSE])
    end
  end
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_runtime_dependency 'activesupport', '>= 5.0', '< 8.0'
  spec.add_runtime_dependency 'colorize', '>= 1.1', '< 2'
  spec.add_runtime_dependency 'launchy', '>= 3.0', '< 4'
  spec.add_runtime_dependency 'nokogiri', '>= 1.18.3', '< 2'

  spec.add_development_dependency 'activerecord', '>= 5.0', '< 8.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'ruby-lsp'
  spec.add_development_dependency 'shoulda-context', '~> 3.0.0.rc1'
  spec.add_development_dependency 'shoulda-matchers', '~> 6.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
end
