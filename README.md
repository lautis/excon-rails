# Excon::Rails

Railtie to include Excon HTTP requests in Rails logging.

## Installation

Add this line to your Rails application's Gemfile:

    gem 'excon-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install excon-rails

After you've started your Rails application, your Rails logs should include
Excon HTTP requests.

If you have debug logging enabled, individual requests are printed out:

      Excon Request (105.66ms)  GET https://google.com/
      Excon Response (0.02ms)  302 Found (259 Bytes)


A total runtime is also included per each request:

      Completed 200 OK in 132ms (Views: 0.2ms | ActiveRecord: 0.4ms | excon: 105.7ms)

## Contributing

1. Fork it ( https://github.com/lautis/excon-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
