# Time.measure

The easiest way to measure execution time of your code. No more `puts` or `logger.info` with `Time.now - time`.

Start measuring your code, and if you value your time, use this gem :)

## Installation

```ruby
group :development, :test do
  gem "time_m"
end
```

## Usage

To make is super easy to use, it extends `Time` class with `m` (or `measure`) method. There is also an advanced way to use it, see below.

```ruby
def index
  Time.m("report_time") do
    @report = prepare_some_report
  end
end

# or

def index
  Time.m
  some_method_1
  Time.m
  some_method_2
  Time.m
  some_method_3
  Time.m
end
```

## How it works

Under the hood, it uses `Process.clock_gettime(Process::CLOCK_MONOTONIC)` to get the current time.

After first call, it stores the time in a thread-local variable using `Thread.current`.

With second call, it calculates the difference between the current time and the time stored in the thread-local variable.

## Advanced usage

Support of multiple timers. You can call any method (it's using `method_missing` under the hood) to start a new timer with it's name.

It will print duration if the same method is called again.

```ruby
def index
  TM.index
  TM.some_method_1
  some_method_1
  TM.some_method_1
  TM.some_method_2
  some_method_2
  TM.some_method_2
  TM.index
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO

- config for colors
- config to specify print of caller
- config to enable extension for Time class
- config for custom output
- Instrumentation support?

## Contributing

You are welcome to contribute to the project.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
