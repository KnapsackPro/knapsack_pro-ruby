describe KnapsackPro::LoggerWrapper do
  let(:io) { StringIO.new }
  let(:logger) { ::Logger.new(io) }
  let(:logger_wrapper) { described_class.new(logger) }

  subject { io.string }

  [:debug, :info, :warn, :error, :fatal].each do |log_level|
    describe "##{log_level}" do
      before {logger_wrapper.public_send(log_level, 'Test message') }

      it { should eq "[knapsack_pro] Test message\n" }
    end
  end
end
