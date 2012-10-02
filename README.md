# Check

[![travis][1]][2]

Redis backed service for monitoring metric data streams against
pre-defined thresholds.

## Installation

Add this line to your application's Gemfile:

    gem 'check'

And then run:

    $ bundle

Or install it yourself as:

    $ gem install check

## Usage

Check the examples directory. To run a specific example:

    $ ruby examples/metric_check.rb

NB: you will need to have all gems in the `development` group installed.

## Benchmarks

Check the benchmarks directory. To run a specific benchmark:

    $ ruby benchmarks/metric_check.rb

NB: you will need to have all gems in `development` group installed.

## API

The gem comes with a self-contained API. It's powered by grape and
it includes a config.ru and unicorn.conf (check the examples folder).

Unicorn is **not** declared as a dependency, feel free to choose
whichever ruby web server you prefer in the service implementing this
gem.

If you have the gem repository cloned and want to test out the API:

    unicorn -c examples/unicorn.conf.rb examples/config.ru

## Notifications

Check uses redis pub/sub to notify of new positives. There is a
`Check::Notifications` class which should make it easy to set up and
configure your own subscriber. It the simplest form, it looks like this:

```ruby
require 'check/notifications'

Check::Notifications.new
```

The default notifications subscriber is highly customizable, but if this
isn't enough, feel free to use it as an example for rolling your own.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[1]: https://secure.travis-ci.org/gosquared/check.png
[2]: http://travis-ci.org/gosquared/check
