require 'open3'
require 'ostruct'

require_relative '../../../lib/knapsack_pro/rspec/test_queue_initializer'

describe "#{KnapsackPro::RSpec::TestQueueInitializer} - Integration tests", :clear_tmp do
  SPEC_DIRECTORY = 'spec_integration'

  class Spec
    attr_reader :path, :content

    def initialize(path, content)
      @path = "#{SPEC_DIRECTORY}/#{path}"
      @content = content
    end
  end

  # @param rspec_options String
  # @param specs Array[String]
  def generate_specs(rspec_options, specs)
    ENV['TEST__RSPEC_OPTIONS'] = rspec_options
    generate_spec_files(specs)
  end

  def generate_spec_files(specs)
    specs.map do |spec_item|
      File.open(spec_item.path, 'w') { |file| file.write(spec_item.content) }
      spec_item.path
    end
  end

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

  let(:command) { 'ruby spec/integration/rspec/test_queue_initializer.rb' }

  subject do
    stdout, stderr, status = Open3.capture3(command)
    log(stdout, stderr, status) if ENV['TEST__SHOW_DEBUG_LOG'] == 'true'
    OpenStruct.new(stdout: stdout, stderr: stderr, exit_code: status.exitstatus)
  end

  before do
    FileUtils.mkdir_p(SPEC_DIRECTORY)

    ENV['KNAPSACK_PRO_LOG_LEVEL'] = 'debug'
    # Useful when creating or editing a test:
    # ENV['TEST__SHOW_DEBUG_LOG'] = 'true'
  end
  after do
    FileUtils.rm_rf(SPEC_DIRECTORY)
    FileUtils.mkdir_p(SPEC_DIRECTORY)

    ENV.delete('KNAPSACK_PRO_LOG_LEVEL')
    ENV.keys.select { _1.start_with?('TEST__') }.each do |key|
      ENV.delete(key)
    end
  end

  before do
    ENV['KNAPSACK_PRO_CI_NODE_TOTAL'] = '2'
  end
  after do
    ENV.delete('KNAPSACK_PRO_CI_NODE_TOTAL')
  end

  it 'initializes the queue' do
    rspec_options = ''

    fast_spec = Spec.new('fast_spec.rb', <<~SPEC)
      describe 'A_describe' do
        it 'A1 test example' do
          expect(1).to eq 1
        end

        it 'A2 test example' do
          expect(1).to eq 1
        end
      end
    SPEC

    slow_spec = Spec.new('slow_spec.rb', <<~SPEC)
      describe 'B_describe' do
        it 'B1 test example' do
          expect(1).to eq 1
        end

        it 'B2 test example' do
          expect(1).to eq 1
        end
      end
    SPEC

    generate_specs(rspec_options, [fast_spec, slow_spec])

    actual = subject

    expect(actual.stdout).to include('DEBUG -- knapsack_pro: GET https://api.knapsackpro.com/v1/build_distributions/last').once
    expect(actual.stdout).to include('INFO -- knapsack_pro: Calculating Split by Test Examples. Analyzing 1 slow test files').once
    expect(actual.stdout).to include('DEBUG -- knapsack_pro: POST https://api.knapsackpro.com/v2/queues/queue').twice
    expect(actual.stdout).to include('"test_files":[{"path":"spec_integration/fast_spec.rb[1:1]"},{"path":"spec_integration/fast_spec.rb[1:2]"},{"path":"spec_integration/slow_spec.rb[1:1]"},{"path":"spec_integration/slow_spec.rb[1:2]"}]').once
    expect(actual.stdout).to include('INFO -- knapsack_pro: Test Queue URL: http://example.com').once

    expect(actual.exit_code).to eq 0
  end
end
