require 'open3'
require 'json'

describe "#{KnapsackPro::Runners::Queue::RSpecRunner} - Integration tests" do
  SPEC_DIRECTORY = 'spec_integration'
  class SpecItem
    attr_reader :path, :content

    def initialize(path, content)
      @path = "#{SPEC_DIRECTORY}/#{path}"
      @content = content
    end
  end

  # @param rspec_options String
  def run_specs(spec_helper_content, rspec_options, spec_items)
    ENV['TEST__RSPEC_OPTIONS'] = rspec_options

    spec_helper_path = "#{SPEC_DIRECTORY}/spec_helper.rb"
    File.open(spec_helper_path, 'w') { |file| file.write(spec_helper_content) }

    paths = spec_items.map do |spec_item|
      File.open(spec_item.path, 'w') { |file| file.write(spec_item.content) }
      spec_item.path
    end

    yield
  ensure
    File.delete(spec_helper_path)
    paths.each { |path| File.delete(path) }
  end

  def mock_batched_tests(batched_tests)
    ENV['TEST__BATCHED_TESTS'] = batched_tests.to_json
  end

  def log_command_result(stdout, stderr, status)
    return if ENV['TEST__SHOW_DEBUG_LOG'] != 'true'

    puts '='*50
    puts 'STDOUT'
    puts stdout
    puts

    puts '='*50
    puts 'STDERR'
    puts stderr
    puts

    puts '='*50
    puts 'Exit status code'
    puts status
    puts
  end

  let(:spec_helper_with_knapsack) do
    <<~SPEC
    require 'knapsack_pro'

    KnapsackPro::Adapters::RSpecAdapter.bind
    SPEC
  end

  subject do
    command = "ruby #{SPEC_DIRECTORY}/queue_runner.rb"
    stdout, stderr, status = Open3.capture3(command)
    log_command_result(stdout, stderr, status)
    OpenStruct.new(stdout: stdout, stderr: stderr, exit_code: status.exitstatus)
  end

  before do
    # uncomment to show output from the Queue RSpec run for each test example
    ENV['TEST__SHOW_DEBUG_LOG'] = 'true'
  end

  context 'when a few batches of tests returned by the Queue API' do
    let(:rspec_options) { '--format d' }

    it do
      spec_a = SpecItem.new(
        'a_spec.rb',
        <<~SPEC
        describe "A_describe" do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
        SPEC
      )

      spec_b = SpecItem.new(
        'b_spec.rb',
        <<~SPEC
        describe "B_describe" do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
        SPEC
      )

      spec_c = SpecItem.new(
        'c_spec.rb',
        <<~SPEC
        describe "C_describe" do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
        SPEC
      )

      run_specs(spec_helper_with_knapsack, rspec_options, [
        spec_a,
        spec_b,
        spec_c
      ]) do
        mock_batched_tests([
          [spec_a.path, spec_b.path],
          [spec_c.path],
        ])

        result = subject

        # expect RSpecAdapter.bind method to be called for Queue Mode
        # expect logger to print to stdout
        expect(result.stdout).to include('DEBUG -- : [knapsack_pro] Test suite time execution queue recording enabled.')

        # expect to execute test examples from all batches
        # expect output to be a documentation when the --format option is provided
        expect(result.stdout).to include('A1 test example')
        expect(result.stdout).to include('B1 test example')
        expect(result.stdout).to include('C1 test example')

        # expect copy & paste command to reproduce tests for each batch of tests
        expect(result.stdout).to include('INFO -- : [knapsack_pro] To retry the last batch of tests fetched from the Queue API, please run the following command on your machine:')
        expect(result.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --format d --default-path spec_integration "spec_integration/a_spec.rb" "spec_integration/b_spec.rb"')
        expect(result.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --format d --default-path spec_integration "spec_integration/c_spec.rb"')

        # expect copy & paste command to reproduce tests for the CI node
        expect(result.stdout).to include('INFO -- : [knapsack_pro] To retry all the tests assigned to this CI node, please run the following command on your machine:')
        expect(result.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --format d --default-path spec_integration "spec_integration/a_spec.rb" "spec_integration/b_spec.rb" "spec_integration/c_spec.rb"')

        # expect RSpec to show a summary with a correct number of test examples
        expect(result.stdout).to include('3 examples, 0 failures')

        # expect Knapsack Pro presenter with global time
        expect(result.stdout).to include('DEBUG -- : [knapsack_pro] Global time execution for tests:')

        # expect successful tests
        expect(result.exit_code).to eq 0
      end
    end
  end
end
