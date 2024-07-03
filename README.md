# QueryCounter

`QueryCounter` is a Ruby gem designed to help you track and analyze SQL queries executed by your ActiveRecord models. By subscribing to ActiveSupport notifications, it provides detailed insights into the queries being run, including the tables involved and the locations in your code where the queries are generated.
Also, you can compare two codes to view the difference in SQL counts on locations.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'query_counter'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install query_counter

## Usage

There are three ways of using this gem:

1. With a block of code

```ruby
require 'query_counter'

QueryCounter.start_with_block(printer: :html) do 
    # your code goes here
end
```
this will open up a html table with the SQL stats of your code
2. Starting recording manually
```ruby
require 'query_counter'

QueryCounter.start_recording 
# your code goes here
QueryCounter.end_recording(printer: :html)
```

3. Comparing two blocks of code 

```ruby
require 'query_counter'
QueryCounter.compare do |bench|
    bench.code('script1') do 
    end 
    bench.code('script2') do 
    end 
    bench.compare!
end
```
this will open up a graph comparing the quantity of SQL of the two codes

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/query_counter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/query_counter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the QueryCounter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/query_counter/blob/master/CODE_OF_CONDUCT.md).
