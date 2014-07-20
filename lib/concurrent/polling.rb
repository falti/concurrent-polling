require "concurrent"
require "concurrent/polling/version"
require "values"

module Concurrent

  module Polling
    DEFAULT_OPTIONS = {
      retries: 1,
      success_condition: lambda {|polled_value| true },
      poll: lambda { :default_options_polling_result }
    }


    TimeoutError = Class.new(StandardError)
    ConditionError = Class.new(StandardError)

    class TempResult < Value.new(:ok, :retries, :reason); end
    class FinalResult < Value.new(:ok, :reason); end

    class Solver

      def initialize(poll_function, check_function)
        @poll_function = poll_function
        @check_function = check_function
      end

      def solve(result)

        condition_met = begin
          @check_function.call(result.ok)
        rescue Exception => e
          raise ConditionError.new(e)
        end

        if(condition_met)
          result
        elsif result.retries == 0
          raise TimeoutError.new
        else

          future = Concurrent::Future.new(&@poll_function).execute

          future_result = future.value # blocking

          solve(TempResult.new(future_result, (result.retries - 1) , nil))
        end
      end
    end

    def self.poll(options = {})

      opts = DEFAULT_OPTIONS.merge(options)

      success_condition = opts[:success_condition]
      poll = opts[:poll]


      retries = opts[:retries]

      solver = Solver.new(poll, success_condition )
      promise = Promise.new{ solver.solve(TempResult.new(poll.call(), retries, nil)) }
        .rescue { |reason| FinalResult.with(ok: nil, reason: reason)}
        .then { |result| FinalResult.new(result.ok, result.reason) }

      promise.execute
      promise.value
    end
  end
end
