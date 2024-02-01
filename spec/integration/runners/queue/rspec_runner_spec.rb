require 'open3'
require 'json'

describe "#{KnapsackPro::Runners::Queue::RSpecRunner} - Integration tests", :clear_tmp do
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
    it do
      rspec_options = '--format d'

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

  context 'when spec_helper.rb has a missing KnapsackPro::Adapters::RSpecAdapter.bind method' do
    it do
      rspec_options = ''

      spec_helper_content = <<~SPEC
      require 'knapsack_pro'
      SPEC

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

      run_specs(spec_helper_content, rspec_options, [
        spec_a,
        spec_b,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [spec_b.path],
        ])

        result = subject

        expect(result.stdout).to include('ERROR -- : [knapsack_pro] You forgot to call KnapsackPro::Adapters::RSpecAdapter.bind method in your test runner configuration file. It is needed to record test files time execution. Please follow the installation guide to configure your project properly https://knapsackpro.com/perma/ruby/installation-guide')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when RSpec options are not set' do
    it 'uses a default progress formatter' do
      rspec_options = ''

      spec_a = SpecItem.new(
        'a_spec.rb',
        <<~SPEC
        describe "A_describe" do
          it {}
          it {}
          it {}
        end
        SPEC
      )

      spec_b = SpecItem.new(
        'b_spec.rb',
        <<~SPEC
        describe "B_describe" do
          it {}
          it {}
        end
        SPEC
      )

      spec_c = SpecItem.new(
        'c_spec.rb',
        <<~SPEC
        describe "C_describe" do
          it {}
          it {}
          it {}
        end
        SPEC
      )

      run_specs(spec_helper_with_knapsack, rspec_options, [
        spec_a,
        spec_b,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, spec_b.path],
          [spec_c.path],
        ])

        result = subject

        beginning_of_knapsack_pro_log_info_message = 'I, ['

        # shows dots for the 1st batch of tests
        expect(result.stdout).to include('.....' + beginning_of_knapsack_pro_log_info_message)
        # shows dots for the 2nd batch of tests
        expect(result.stdout).to include('...' + beginning_of_knapsack_pro_log_info_message)

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when RSpec options are not set AND Knapsack Pro log level is warn' do
    before do
      ENV['KNAPSACK_PRO_LOG_LEVEL'] = 'warn'
      ENV.delete('TEST__SHOW_DEBUG_LOG')
    end
    after do
      ENV.delete('KNAPSACK_PRO_LOG_LEVEL')
    end

    it 'uses a default progress formatter and shows dots for all test examples' do
      rspec_options = ''

      spec_a = SpecItem.new(
        'a_spec.rb',
        <<~SPEC
        describe "A_describe" do
          it {}
          it {}
          it {}
        end
        SPEC
      )

      spec_b = SpecItem.new(
        'b_spec.rb',
        <<~SPEC
        describe "B_describe" do
          it {}
          it {}
        end
        SPEC
      )

      spec_c = SpecItem.new(
        'c_spec.rb',
        <<~SPEC
        describe "C_describe" do
          it {}
          it {}
          it {}
        end
        SPEC
      )

      run_specs(spec_helper_with_knapsack, rspec_options, [
        spec_a,
        spec_b,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('.'*8)

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when hooks are defined' do
    it 'calls RSpec before/after hooks only once for multiple batches of tests' do
      rspec_options = ''

      spec_helper_content = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.before(:suite) do
          puts "RSpec_before_suite_hook"
        end
        config.after(:suite) do
          puts "RSpec_after_suite_hook"
        end
      end
      SPEC

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

      run_specs(spec_helper_content, rspec_options, [
        spec_a,
        spec_b,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout.scan(/RSpec_before_suite_hook/).size).to eq 1
        expect(result.stdout.scan(/RSpec_after_suite_hook/).size).to eq 1

        expect(result.exit_code).to eq 0
      end
    end

    it 'calls queue hooks for multiple batches of tests (queue hooks can be defined multiple times)' do
      rspec_options = ''

      spec_helper_content = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      KnapsackPro::Hooks::Queue.before_queue do |queue_id|
        puts '1st before_queue - run before the test suite'
      end
      KnapsackPro::Hooks::Queue.before_queue do |queue_id|
        puts '2nd before_queue - run before the test suite'
      end

      KnapsackPro::Hooks::Queue.before_subset_queue do |queue_id, subset_queue_id|
        puts '1st before_subset_queue - run before the next subset of tests'
      end
      KnapsackPro::Hooks::Queue.before_subset_queue do |queue_id, subset_queue_id|
        puts '2nd before_subset_queue - run before the next subset of tests'
      end

      KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
        puts '1st after_subset_queue - run after the previous subset of tests'
      end
      KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
        puts '2nd after_subset_queue - run after the previous subset of tests'
      end

      KnapsackPro::Hooks::Queue.after_queue do |queue_id|
        puts '1st after_queue - run after the test suite'
      end
      KnapsackPro::Hooks::Queue.after_queue do |queue_id|
        puts '2nd after_queue - run after the test suite'
      end
      SPEC

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

      run_specs(spec_helper_content, rspec_options, [
        spec_a,
        spec_b,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout.scan(/1st before_queue - run before the test suite/).size).to eq 1
        expect(result.stdout.scan(/2nd before_queue - run before the test suite/).size).to eq 1
        expect(result.stdout.scan(/1st before_subset_queue - run before the next subset of tests/).size).to eq 2
        expect(result.stdout.scan(/2nd before_subset_queue - run before the next subset of tests/).size).to eq 2
        expect(result.stdout.scan(/1st after_subset_queue - run after the previous subset of tests/).size).to eq 2
        expect(result.stdout.scan(/2nd after_subset_queue - run after the previous subset of tests/).size).to eq 2
        expect(result.stdout.scan(/1st after_queue - run after the test suite/).size).to eq 1
        expect(result.stdout.scan(/2nd after_queue - run after the test suite/).size).to eq 1

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when the RSpec seed is used' do
    it do
      rspec_options = '--order rand:123'

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
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('Randomized with seed 123')

        # 1st batch
        expect(result.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --order rand:123 --format progress --default-path spec_integration "spec_integration/a_spec.rb" "spec_integration/b_spec.rb"')
        # 2nd batch
        expect(result.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --order rand:123 --format progress --default-path spec_integration "spec_integration/c_spec.rb"')

        # final copy & paste command with seed
        expect(result.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --order rand:123 --format progress --default-path spec_integration "spec_integration/a_spec.rb" "spec_integration/b_spec.rb" "spec_integration/c_spec.rb"')

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when a failing test in a batch of tests that is not the last batch fetched from the Queue API' do
    it 'returns 1 as exit code (it remembers that one of the batches has a failing test)' do
      rspec_options = '--format documentation'

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

      failing_spec = SpecItem.new(
        'failing_spec.rb',
        <<~SPEC
        describe "B_describe" do
          it 'B1 test example' do
            expect(1).to eq 0
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
        failing_spec,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, failing_spec.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('B1 test example (FAILED - 1)')
        expect(result.stdout).to include('Failure/Error: expect(1).to eq 0')
        expect(result.stdout).to include('3 examples, 1 failure')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when a failing test raises an exception' do
    it 'returns 1 as exit code and the exception does not leak outside of the RSpec runner context' do
      rspec_options = '--format documentation'

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

      failing_spec = SpecItem.new(
        'failing_spec.rb',
        <<~SPEC
        describe "B_describe" do
          it 'B1 test example' do
            raise 'ACustomException'
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
        failing_spec,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, failing_spec.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('B1 test example (FAILED - 1)')
        expect(result.stdout).to include("Failure/Error: raise 'ACustomException'")
        expect(result.stdout).to include('3 examples, 1 failure')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when a spec file has a syntax error outside of the test example' do
    it 'stops running tests on the batch that has a test file with the syntax error AND returns 1 as exit code' do
      rspec_options = '--format documentation'

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

      failing_spec = SpecItem.new(
        'failing_spec.rb',
        <<~SPEC
        describe "B_describe" do
          a_fake_method

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
        failing_spec,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [failing_spec.path],
          [spec_c.path],
        ])

        result = subject

        # 1st batch of tests executed correctly
        expect(result.stdout).to include('A1 test example')
        # 2nd batch contains the test file that cannot be loaded and the test file is not executed
        expect(result.stdout).to_not include('B1 test example')
        # 3rd batch is never executed
        expect(result.stdout).to_not include('C1 test example')

        expect(result.stdout).to include('An error occurred while loading ./spec_integration/failing_spec.rb')
        expect(result.stdout).to include("undefined local variable or method `a_fake_method' for RSpec::ExampleGroups::BDescribe:Class")
        expect(result.stdout).to include('WARN -- : [knapsack_pro] RSpec wants to quit')
        expect(result.stdout).to include('1 example, 0 failures, 1 error occurred outside of examples')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when a syntax error (an exception) in spec_helper.rb' do
    it 'returns 1 as exit code because RSpec wants to quit and exit early without running tests' do
      rspec_options = '--format documentation'

      spec_helper_content = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      a_fake_method
      SPEC

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

      run_specs(spec_helper_content, rspec_options, [
        spec_a,
        spec_b,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [spec_b.path],
        ])

        result = subject

        expect(result.stdout).to include('An error occurred while loading spec_helper.')
        expect(result.stdout).to include("undefined local variable or method `a_fake_method' for main:Object")
        expect(result.stdout).to include('0 examples, 0 failures, 1 error occurred outside of examples')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when the test suite has pending tests' do
    it 'shows the summary of pending tests' do
      rspec_options = '--format documentation'

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
          xit 'B1 test example' do
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

          xit 'C2 test example' do
            expect(1).to eq 1
          end
        end
        SPEC
      )

      run_specs(spec_helper_with_knapsack, rspec_options, [
        spec_a,
        spec_b,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('B1 test example (PENDING: Temporarily skipped with xit)')
        expect(result.stdout).to include('C2 test example (PENDING: Temporarily skipped with xit)')

        expect(result.stdout).to include("Pending: (Failures listed here are expected and do not affect your suite's status)")
        expect(result.stdout).to include('1) B_describe B1 test example')
        expect(result.stdout).to include('2) C_describe C2 test example')

        expect(result.stdout).to include('4 examples, 0 failures, 2 pending')

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when a test file raises an exception that cannot be handle by RSpec' do
    it 'stops running tests when unhandled exception happens and sets 1 as exit code and shows summary of unexecuted tests' do
      rspec_options = '--format documentation'

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

      # list of unhandled exceptions:
      # RSpec::Support::AllExceptionsExceptOnesWeMustNotRescue::AVOID_RESCUING
      spec_b = SpecItem.new(
        'b_spec.rb',
        <<~SPEC
        describe "B_describe" do
          it 'B1 test example' do
            raise NoMemoryError.new
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
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('A1 test example')

        expect(result.stdout).to include('B_describe')
        expect(result.stdout).to include('An unexpected exception happened. RSpec cannot handle it. The exception: #<NoMemoryError: NoMemoryError>')
        expect(result.stdout).to_not include('B1 test example')

        expect(result.stdout).to_not include('C1 test example')

        # 2nd test example raised unhandled exception during runtime.
        # It breaks RSpec so it was not marked as failed.
        expect(result.stdout).to include('2 examples, 0 failures')

        expect(result.stdout).to include('WARN -- : [knapsack_pro] Unexecuted tests on this CI node (including pending tests): spec_integration/b_spec.rb')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when a test file raises an exception that cannot be handle by RSpec AND --error-exit-code is set' do
    it 'sets a custom exit code' do
      rspec_options = '--format documentation --error-exit-code 2'

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
            raise NoMemoryError.new
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
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.exit_code).to eq 2
      end
    end
  end

  context 'when a termination signal is received by the process' do
    it 'terminates the process after tests from the current RSpec ExampleGroup are executed and sets 1 as exit code' do
      rspec_options = '--format documentation'

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
        describe "B1_describe" do
          describe "B1.1_describe" do
            it 'B1.1.1 test example' do
              expect(1).to eq 1
            end
            it 'B1.1.2 test example' do
              Process.kill("INT", Process.pid)
            end
            it 'B1.1.3 test example' do
              expect(1).to eq 1
            end
          end

          describe "B1.2_describe" do
            it 'B1.2.1 test example' do
              expect(1).to eq 1
            end
          end
        end

        describe "B2_describe" do
          it 'B2.1 test example' do
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

      spec_d = SpecItem.new(
        'd_spec.rb',
        <<~SPEC
        describe "D_describe" do
          it 'D1 test example' do
            expect(1).to eq 1
          end
        end
        SPEC
      )

      run_specs(spec_helper_with_knapsack, rspec_options, [
        spec_a,
        spec_b,
        spec_c,
        spec_d,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [spec_b.path, spec_c.path],
          [spec_d.path],
        ])

        result = subject

        expect(result.stdout).to include('B1.1.1 test example')
        expect(result.stdout).to include('INT signal has been received. Terminating Knapsack Pro...')
        expect(result.stdout).to include('B1.1.2 test example')
        expect(result.stdout).to include('B1.1.3 test example')
        expect(result.stdout).to include('B1.2.1 test example')

        # next ExampleGroup within the same b_spec.rb is not executed
        expect(result.stdout).to_not include('B2.1 test example')

        # next test file from the same batch is not executed
        expect(result.stdout).to_not include('C1 test example')

        # next batch of tests is not pulled from the Queue API and is not executed
        expect(result.stdout).to_not include('D1 test example')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when a termination signal is received by the process AND --error-exit-code is set' do
    it 'terminates the process and sets a custom exit code' do
      rspec_options = '--format documentation --error-exit-code 3'

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
            Process.kill("INT", Process.pid)
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
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('INT signal has been received. Terminating Knapsack Pro...')

        expect(result.exit_code).to eq 3
      end
    end
  end

  context 'when deprecated run_all_when_everything_filtered option is true' do
    it 'shows error message and sets 1 as exit code' do
      rspec_options = '--format documentation'

      spec_helper_content = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.run_all_when_everything_filtered = true
      end
      SPEC

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

      run_specs(spec_helper_content, rspec_options, [
        spec_a,
        spec_b,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [spec_b.path],
        ])

        result = subject

        expect(result.stdout).to include('ERROR -- : [knapsack_pro] The run_all_when_everything_filtered option is deprecated. See: https://knapsackpro.com/perma/ruby/rspec-deprecated-run-all-when-everything-filtered')

        expect(result.stdout).to_not include('A1 test example')
        expect(result.stdout).to_not include('B1 test example')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when the late CI node has an empty batch of tests because other CI nodes already consumed tests from the Queue API' do
    it 'sets 0 as exit code' do
      rspec_options = '--format documentation'

      run_specs(spec_helper_with_knapsack, rspec_options, []) do
        mock_batched_tests([])

        result = subject

        expect(result.stdout).to include('0 examples, 0 failures')
        expect(result.stdout).to include('WARN -- : [knapsack_pro] No test files were executed on this CI node.')
        expect(result.stdout).to include('DEBUG -- : [knapsack_pro] This CI node likely started work late after the test files were already executed by other CI nodes consuming the queue.')

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when the fail_if_no_examples option is true AND the late CI node has an empty batch of tests because other CI nodes already consumed tests from the Queue API' do
    it 'sets 0 as exit code to ignore the fail_if_no_examples option' do
      rspec_options = '--format documentation'

      spec_helper_content = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.fail_if_no_examples = true
      end
      SPEC

      run_specs(spec_helper_content, rspec_options, []) do
        mock_batched_tests([])

        result = subject

        expect(result.stdout).to include('0 examples, 0 failures')
        expect(result.stdout).to include('WARN -- : [knapsack_pro] No test files were executed on this CI node.')
        expect(result.stdout).to include('DEBUG -- : [knapsack_pro] This CI node likely started work late after the test files were already executed by other CI nodes consuming the queue.')

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when the fail_if_no_examples option is true AND a batch of tests has a test file without test examples' do
    it 'sets 0 as exit code to ignore the fail_if_no_examples option' do
      rspec_options = '--format documentation'

      spec_helper_content = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.fail_if_no_examples = true
      end
      SPEC

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

      run_specs(spec_helper_content, rspec_options, [
        spec_a,
        spec_b,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path],
          [spec_b.path], # batch with no test examples
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('2 examples, 0 failures')

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when tests are failing AND --failure-exit-code is set' do
    it 'returns a custom exit code' do
      rspec_options = '--format documentation --failure-exit-code 4'

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

      failing_spec = SpecItem.new(
        'failing_spec.rb',
        <<~SPEC
        describe "B_describe" do
          it 'B1 test example' do
            expect(1).to eq 0
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
        failing_spec,
        spec_c,
      ]) do
        mock_batched_tests([
          [spec_a.path, failing_spec.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('B1 test example (FAILED - 1)')
        expect(result.stdout).to include('Failure/Error: expect(1).to eq 0')
        expect(result.stdout).to include('3 examples, 1 failure')

        expect(result.exit_code).to eq 4
      end
    end
  end

  context 'when --profile is set' do
    it 'shows top slowest examples and example groups' do
      rspec_options = '--format d --profile'

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

        expect(result.stdout).to include('Top 3 slowest examples')
        expect(result.stdout).to include('A_describe A1 test example')
        expect(result.stdout).to include('B_describe B1 test example')
        expect(result.stdout).to include('C_describe C1 test example')

        expect(result.stdout).to include('Top 3 slowest example groups')

        expect(result.exit_code).to eq 0
      end
    end
  end

  context 'when an invalid RSpec option is set' do
    it 'returns 1 as exit code and shows an error message to stderr' do
      rspec_options = '--format d --fake-rspec-option'

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

        expect(result.stderr).to include('invalid option: --fake-rspec-option')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when --fail-fast is set' do
    it 'stops running tests on the failing test AND returns 1 as exit code AND shows a warning message' do
      rspec_options = '--format d --fail-fast'

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
            expect(1).to eq 0
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
          it 'C2 test example' do
            expect(1).to eq 0
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

        expect(result.stdout).to include('A1 test example')
        expect(result.stdout).to include('B1 test example')
        expect(result.stdout).to_not include('C1 test example')
        expect(result.stdout).to_not include('C2 test example')

        expect(result.stdout).to include('WARN -- : [knapsack_pro] Test execution has been canceled because the RSpec --fail-fast option is enabled. It can cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')

        expect(result.stdout).to include('2 examples, 1 failure')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when the fail_fast option is set with a specific number of tests' do
    it 'stops running tests on the 2nd failing test AND returns 1 as exit code AND shows a warning message when fail fast limit met' do
      rspec_options = '--format d'

      spec_helper_content = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.fail_fast = 2
      end
      SPEC

      spec_a = SpecItem.new(
        'a_spec.rb',
        <<~SPEC
        describe "A_describe" do
          it 'A1 test example' do
            expect(1).to eq 0
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
          it 'B2 test example' do
            expect(1).to eq 0
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
          it 'C2 test example' do
            expect(1).to eq 1
          end
        end
        SPEC
      )

      run_specs(spec_helper_content, rspec_options, [
        spec_a,
        spec_b,
        spec_c
      ]) do
        mock_batched_tests([
          [spec_a.path, spec_b.path],
          [spec_c.path],
        ])

        result = subject

        expect(result.stdout).to include('A1 test example (FAILED - 1)')
        expect(result.stdout).to include('B1 test example')
        expect(result.stdout).to include('B2 test example (FAILED - 2)')
        expect(result.stdout).to_not include('C1 test example')
        expect(result.stdout).to_not include('C2 test example')

        expect(result.stdout).to include('WARN -- : [knapsack_pro] Test execution has been canceled because the RSpec --fail-fast option is enabled. It can cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')

        expect(result.stdout).to include('3 examples, 2 failures')

        expect(result.exit_code).to eq 1
      end
    end
  end

  context 'when --tag is set' do
    it 'runs only tagged test examples' do
      rspec_options = '--format d --tag my_tag'

      spec_a = SpecItem.new(
        'a_spec.rb',
        <<~SPEC
        describe "A_describe" do
          it 'A1 test example' do
            expect(1).to eq 1
          end
          it 'A2 test example', :my_tag do
            expect(1).to eq 1
          end
        end
        SPEC
      )

      spec_b = SpecItem.new(
        'b_spec.rb',
        <<~SPEC
        describe "B_describe", :my_tag do
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

        expect(result.stdout).to_not include('A1 test example')
        expect(result.stdout).to include('A2 test example')

        expect(result.stdout).to include('B1 test example')

        expect(result.stdout).to_not include('C1 test example')

        expect(result.exit_code).to eq 0
      end
    end
  end
end
