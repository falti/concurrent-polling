# Concurrent::Polling

[![Build Status](https://travis-ci.org/falti/concurrent-polling.svg?branch=master)](https://travis-ci.org/falti/concurrent-polling)
[![Dependency Status](https://gemnasium.com/falti/concurrent-polling.svg)](https://gemnasium.com/falti/concurrent-polling)
[![Code Climate](https://codeclimate.com/github/falti/concurrent-polling.png)](https://codeclimate.com/github/falti/concurrent-polling)
[![Coverage Status](https://coveralls.io/repos/falti/concurrent-polling/badge.png?branch=master)](https://coveralls.io/r/falti/concurrent-polling?branch=master)

This is a simple library to implement polling using the concurrent-ruby gem.
It has probably some bugs, especially if really used excessively in a typical multithreaded application.
I needed it to poll status from a service and it works for me.

I would be more than happy to receive some feedback how to improve the gem.

## Installation

Add this line to your application's Gemfile:

    gem 'concurrent-polling'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install concurrent-polling

## Usage

    polling_result = Concurrent::Polling.poll(
      retries: 10,
      success_condition: lambda {|result| true },
      poll: lambda { "success" })

    polling_result.ok  # => "success"

    polling_failed_result = Concurrent::Polling.poll(
      retries: 10,
      success_condition: lambda {|result| true },
      poll: lambda { raise "boom!" }) # this also works if the success_condition raises error!

    polling_failed_result.ok  # => nik
    polling_failed_result.reason # RuntimeError


    polling_timeout_result = Concurrent::Polling.poll(
      retries: 10,
      success_condition: lambda {|result| false }, # result always rejected
      poll: lambda { "too good to be true" })

    polling_timeout_result.reason # => TimeoutError

The polling result will have 2 fields, #ok and #reason.
If result.ok != nil then your polling was successful, in this case result.reason will be nil.
On the other hand, if polling failed (or did not finish in time), the result.ok will be nil and
the result.reason contains the error that was raised by the supplied lambdas or a TimeoutError
which will be raised if the success_condition never evaluates to true for any polling result.

In case you need some delay between the polling you need to add some sleep(n) in that block.
I might add such a feature later. So far it's 'aggressive' means it will poll all the time.


## Contributing

1. Fork it ( http://github.com/falti/concurrent-polling/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
