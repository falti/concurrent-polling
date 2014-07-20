
RSpec.describe Concurrent::Polling do

  it "should poll with default options" do
    polling_result = Concurrent::Polling.poll()
    expect(polling_result.ok).to eq(:default_options_polling_result)
  end

  it "should handle exceptions on the poll proc" do
    polling_result = Concurrent::Polling.poll(poll: lambda{ raise "polling boom" })

    expect(polling_result.ok).to be_nil
    expect(polling_result.reason).to be_a RuntimeError
  end



  it "should handle expection on the success_condition proc" do
    polling_result = Concurrent::Polling.poll(success_condition: lambda{|result| raise "some error" })
    expect(polling_result.ok).to be_nil
    expect(polling_result.reason).to be_a Concurrent::Polling::ConditionError
  end

  it "should run into timeout" do
    polling_result = Concurrent::Polling.poll(success_condition: lambda{|result| false })


    expect(polling_result.ok).to be_nil
    expect(polling_result.reason).to be_a Concurrent::Polling::TimeoutError

  end

  it "should work with custom options" do

    polling = Concurrent::Polling.poll(
      retries: 10,
      execution_interval: 0.1,
      timeout_interval: 0.01,
      success_condition: lambda {|result| result == "success" },
      poll: Proc.new do
        "success"
      end
    )

    expect(polling.ok).to eq("success")

  end

  describe "Stress Test" do

    it "should work with multiple polls" do
      puts "running the multi test"
      futures = (1..10000).map do |i|

        f = Concurrent::Future.new do
          polling = Concurrent::Polling.poll(
          retries: 10,
          success_condition: lambda {|result| true },
          poll: Proc.new do
            "success"
          end
          )

          polling

          #expect(polling.ok).to eq("success#{i}")
        end

        f.execute
        f.value
      end


      sleep(1)

      futures.each do |f|
        expect(f.ok).to be_truthy
        expect(f.ok).to eq("success")


      end



    end
  end



end