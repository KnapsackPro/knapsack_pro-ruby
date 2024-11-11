require 'open3'
require 'ostruct'
require 'tempfile'

describe "#{KnapsackPro::Runners::Queue::MinitestRunner} Fallback - Integration tests" do
  def log(stdout, stderr, status)
    puts '='*50
    puts 'STDOUT:'
    puts stdout
    puts

    puts '='*50
    puts 'STDERR:'
    puts stderr
    puts

    puts '='*50
    puts 'Exit status code:'
    puts status
    puts
  end

  subject do
    stdout, stderr, status = Open3.capture3("ruby #{@task.path}")
    log(stdout, stderr, status) if ENV['TEST__SHOW_DEBUG_LOG'] == 'true'
    OpenStruct.new(stdout: stdout, stderr: stderr, exit_code: status.exitstatus)
  end

  before(:each) do
    ENV['KNAPSACK_PRO_ENDPOINT'] = 'https://fail.knapsackpro.com' # ensure the API is not reachable
    ENV['KNAPSACK_PRO_MAX_REQUEST_RETRIES'] = '1' # only try once to reach the API
  end

  around(:each) do |example|
    Tempfile.create do |file|
      file.write(<<~CONTENT)
        require 'knapsack_pro'

        ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST'] = SecureRandom.hex
        ENV['KNAPSACK_PRO_CI_NODE_BUILD_ID'] = SecureRandom.uuid

        #{KnapsackPro::Runners::Queue::MinitestRunner}.run('')
      CONTENT
      file.rewind

      @task = file
      example.run
    end
  end

  after(:each) do
    ENV.delete('KNAPSACK_PRO_ENDPOINT')
    ENV.delete('KNAPSACK_PRO_MAX_REQUEST_RETRIES')
  end

  context 'with fallback mode disabled' do
    before(:each) do
      ENV['KNAPSACK_PRO_FALLBACK_MODE_ENABLED'] = 'false'
    end

    after(:each) do
      ENV.delete('KNAPSACK_PRO_FALLBACK_MODE_ENABLED')
    end

    it 'exits with 1 and logs the error' do
      actual = subject

      expect(actual.exit_code).to eq 1

      expect(actual.stdout).to include('ERROR -- : [knapsack_pro] Fallback Mode was disabled with KNAPSACK_PRO_FALLBACK_MODE_ENABLED=false. Please restart this CI node to retry tests. Most likely Fallback Mode was disabled due to https://knapsackpro.com/perma/ruby/queue-mode-connection-error-with-fallback-enabled-false')
    end

    context 'with a user defined exit code' do
      before do
        ENV['KNAPSACK_PRO_FALLBACK_MODE_ERROR_EXIT_CODE'] = '123'
      end

      after do
        ENV.delete('KNAPSACK_PRO_FALLBACK_MODE_ERROR_EXIT_CODE')
      end

      it 'exits with the passed exit code and logs the error' do
        actual = subject

        expect(actual.exit_code).to eq 123

        expect(actual.stdout).to include('ERROR -- : [knapsack_pro] Fallback Mode was disabled with KNAPSACK_PRO_FALLBACK_MODE_ENABLED=false. Please restart this CI node to retry tests. Most likely Fallback Mode was disabled due to https://knapsackpro.com/perma/ruby/queue-mode-connection-error-with-fallback-enabled-false')
      end
    end
  end

  context 'with fallback mode enabled and positive node retry count' do
    before(:each) do
      ENV['KNAPSACK_PRO_FALLBACK_MODE_ENABLED'] = 'true'
      ENV['KNAPSACK_PRO_CI_NODE_RETRY_COUNT'] = '1'
    end

    after(:each) do
      ENV.delete('KNAPSACK_PRO_FALLBACK_MODE_ENABLED')
      ENV.delete('KNAPSACK_PRO_CI_NODE_RETRY_COUNT')
    end

    it 'exits with 1 and logs the error' do
      actual = subject

      expect(actual.exit_code).to eq 1

      expect(actual.stdout).to include('ERROR -- : [knapsack_pro] knapsack_pro gem could not connect to Knapsack Pro API and the Fallback Mode cannot be used this time. Running tests in Fallback Mode are not allowed for retried parallel CI node to avoid running the wrong set of tests. Please manually retry this parallel job on your CI server then knapsack_pro gem will try to connect to Knapsack Pro API again and will run a correct set of tests for this CI node. Learn more https://knapsackpro.com/perma/ruby/queue-mode-connection-error-with-fallback-enabled-true-and-positive-retry-count')
    end

    context 'with a user defined exit code' do
      before do
        ENV['KNAPSACK_PRO_FALLBACK_MODE_ERROR_EXIT_CODE'] = '123'
      end

      after do
        ENV.delete('KNAPSACK_PRO_FALLBACK_MODE_ERROR_EXIT_CODE')
      end

      it 'exits with the passed exit code and logs the error' do
        actual = subject

        expect(actual.exit_code).to eq 123

        expect(actual.stdout).to include('ERROR -- : [knapsack_pro] knapsack_pro gem could not connect to Knapsack Pro API and the Fallback Mode cannot be used this time. Running tests in Fallback Mode are not allowed for retried parallel CI node to avoid running the wrong set of tests. Please manually retry this parallel job on your CI server then knapsack_pro gem will try to connect to Knapsack Pro API again and will run a correct set of tests for this CI node. Learn more https://knapsackpro.com/perma/ruby/queue-mode-connection-error-with-fallback-enabled-true-and-positive-retry-count')
      end
    end
  end
end
