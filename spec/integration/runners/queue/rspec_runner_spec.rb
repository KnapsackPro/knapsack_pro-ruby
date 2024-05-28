require 'open3'
require 'json'
require 'nokogiri'

describe "#{KnapsackPro::Runners::Queue::RSpecRunner} - Integration tests", :clear_tmp do
  SPEC_DIRECTORY = 'spec_integration'

  class Spec
    attr_reader :path, :content

    def initialize(path, content)
      @path = "#{SPEC_DIRECTORY}/#{path}"
      @content = content
    end
  end

  # @param rspec_options String
  # @param spec_batches Array[Array[String]]
  def generate_specs(spec_helper, rspec_options, spec_batches)
    ENV['TEST__RSPEC_OPTIONS'] = rspec_options
    generate_spec_helper(spec_helper)
    paths = generate_spec_files(spec_batches.flatten)
    stub_spec_batches(
      spec_batches.map { _1.map(&:path) }
    )
  end

  def generate_spec_helper(spec_helper)
    spec_helper_path = "#{SPEC_DIRECTORY}/spec_helper.rb"
    File.open(spec_helper_path, 'w') { |file| file.write(spec_helper) }
  end

  def generate_spec_files(specs)
    specs.map do |spec_item|
      File.open(spec_item.path, 'w') { |file| file.write(spec_item.content) }
      spec_item.path
    end
  end

  def create_rails_helper_file(rails_helper)
    rails_helper_path = "#{SPEC_DIRECTORY}/rails_helper.rb"
    File.open(rails_helper_path, 'w') { |file| file.write(rails_helper) }
  end

  def stub_spec_batches(batched_tests)
    ENV['TEST__SPEC_BATCHES'] = batched_tests.to_json
  end

  # @param test_file_paths Array[String]
  #   Example: ['spec_integration/a_spec.rb[1:1]']
  def stub_test_cases_for_slow_test_files(test_file_paths)
    ENV['TEST__TEST_FILE_CASES_FOR_SLOW_TEST_FILES'] = test_file_paths.to_json
  end

  def log_command_result(stdout, stderr, status)
    return if ENV['TEST__SHOW_DEBUG_LOG'] != 'true'

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

  let(:spec_helper_with_knapsack) do
    <<~SPEC
    require 'knapsack_pro'
    KnapsackPro::Adapters::RSpecAdapter.bind
    SPEC
  end

  let(:command) { 'ruby spec/integration/runners/queue/rspec_runner.rb' }

  subject do
    stdout, stderr, status = Open3.capture3(command)
    log_command_result(stdout, stderr, status)
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

  context 'when a few batches of tests returned by the Queue API' do
    it 'runs tests' do
      rspec_options = '--format d'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('DEBUG -- : [knapsack_pro] Queue Mode enabled.')

      expect(actual.stdout).to include('A1 test example')
      expect(actual.stdout).to include('B1 test example')
      expect(actual.stdout).to include('C1 test example')

      expect(actual.stdout).to include('INFO -- : [knapsack_pro] To retry the last batch of tests fetched from the Queue API, please run the following command on your machine:')
      expect(actual.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --format d --default-path spec_integration "spec_integration/a_spec.rb" "spec_integration/b_spec.rb"')
      expect(actual.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --format d --default-path spec_integration "spec_integration/c_spec.rb"')

      expect(actual.stdout).to include('INFO -- : [knapsack_pro] To retry all the tests assigned to this CI node, please run the following command on your machine:')
      expect(actual.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --format d --default-path spec_integration "spec_integration/a_spec.rb" "spec_integration/b_spec.rb" "spec_integration/c_spec.rb"')

      expect(actual.stdout).to include('3 examples, 0 failures')

      expect(actual.stdout).to include('DEBUG -- : [knapsack_pro] Global test execution duration:')

      expect(actual.exit_code).to eq 0
    end

    it 'detects test execution times correctly before sending it to API' do
      ENV['TEST__LOG_EXECUTION_TIMES'] = 'true'

      rspec_options = '--format d'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('[INTEGRATION TEST] test_files: 3, test files have execution time: true')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when spec_helper.rb has a missing KnapsackPro::Adapters::RSpecAdapter.bind method' do
    it do
      rspec_options = ''

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a],
        [spec_b],
      ])

      actual = subject

      expect(actual.stdout).to include('ERROR -- : [knapsack_pro] You forgot to call KnapsackPro::Adapters::RSpecAdapter.bind method in your test runner configuration file. It is needed to record test files time execution. Please follow the installation guide to configure your project properly https://knapsackpro.com/perma/ruby/installation-guide')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when RSpec options are not set' do
    before do
      ENV['KNAPSACK_PRO_LOG_LEVEL'] = 'info'
    end

    after do
      ENV.delete('KNAPSACK_PRO_LOG_LEVEL')
    end

    it 'uses a default progress formatter' do
      rspec_options = ''

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it {}
          it {}
          it {}
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it {}
          it {}
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it {}
          it {}
          it {}
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      beginning_of_knapsack_pro_log_info_message = 'I, ['

      # shows dots for the 1st batch of tests
      expect(actual.stdout).to include('.....' + beginning_of_knapsack_pro_log_info_message)
      # shows dots for the 2nd batch of tests
      expect(actual.stdout).to include('...' + beginning_of_knapsack_pro_log_info_message)

      expect(actual.exit_code).to eq 0
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

    it 'uses a default progress formatter AND shows dots for all test examples' do
      rspec_options = ''

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it {}
          it {}
          it {}
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it {}
          it {}
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it {}
          it {}
          it {}
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('.'*8)

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when rails_helper file does not exist' do
    it 'does not require the rails_helper file when running RSpec' do
      rspec_options = ''

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to_not include('--require rails_helper')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when rails_helper file exists' do
    it 'requires the rails_helper file when running RSpec and runs hooks defined within it' do
      rspec_options = ''

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      rails_helper = <<~SPEC
      RSpec.configure do |config|
        config.before(:suite) do
          puts 'RSpec_before_suite_hook_from_rails_helper'
        end
        config.after(:suite) do
          puts 'RSpec_after_suite_hook_from_rails_helper'
        end
      end
      SPEC

      create_rails_helper_file(rails_helper)

      actual = subject

      expect(actual.stdout).to include('--require rails_helper')
      expect(actual.stdout.scan(/RSpec_before_suite_hook_from_rails_helper/).size).to eq 1
      expect(actual.stdout.scan(/RSpec_after_suite_hook_from_rails_helper/).size).to eq 1

      expect(actual.exit_code).to eq 0
    end

    it 'runs suite hooks defined in rails_helper only once, even if file is required multiple times' do
      rspec_options = ''

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        require 'rails_helper'
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        require 'rails_helper'
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        require 'rails_helper'
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      rails_helper = <<~SPEC
      RSpec.configure do |config|
        config.before(:suite) do
          puts 'RSpec_before_suite_hook_from_rails_helper'
        end
        config.after(:suite) do
          puts 'RSpec_after_suite_hook_from_rails_helper'
        end
      end
      SPEC

      create_rails_helper_file(rails_helper)

      actual = subject

      expect(actual.stdout.scan(/RSpec_before_suite_hook_from_rails_helper/).size).to eq 1
      expect(actual.stdout.scan(/RSpec_after_suite_hook_from_rails_helper/).size).to eq 1

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when hooks are defined' do
    it 'calls RSpec before/after hooks only once for multiple batches of tests' do
      rspec_options = ''

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.before(:suite) do
          puts 'RSpec_before_suite_hook'
        end
        config.after(:suite) do
          puts 'RSpec_after_suite_hook'
        end
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout.scan(/RSpec_before_suite_hook/).size).to eq 1
      expect(actual.stdout.scan(/RSpec_after_suite_hook/).size).to eq 1

      expect(actual.exit_code).to eq 0
    end

    it 'calls queue hooks for multiple batches of tests (queue hooks can be defined multiple times)' do
      rspec_options = ''

      spec_helper = <<~SPEC
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

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout.scan(/1st before_queue - run before the test suite/).size).to eq 1
      expect(actual.stdout.scan(/2nd before_queue - run before the test suite/).size).to eq 1
      expect(actual.stdout.scan(/1st before_subset_queue - run before the next subset of tests/).size).to eq 2
      expect(actual.stdout.scan(/2nd before_subset_queue - run before the next subset of tests/).size).to eq 2
      expect(actual.stdout.scan(/1st after_subset_queue - run after the previous subset of tests/).size).to eq 2
      expect(actual.stdout.scan(/2nd after_subset_queue - run after the previous subset of tests/).size).to eq 2
      expect(actual.stdout.scan(/1st after_queue - run after the test suite/).size).to eq 1
      expect(actual.stdout.scan(/2nd after_queue - run after the test suite/).size).to eq 1

      expect(actual.exit_code).to eq 0
    end

    it 'calls hooks defined with when_first_matching_example_defined only once for multiple batches of tests' do
      rspec_options = '--format documentation'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      def when_first_matching_example_defined(type:)
        env_var_name = "WHEN_FIRST_MATCHING_EXAMPLE_DEFINED_FOR_" + type.to_s.upcase

        RSpec.configure do |config|
          config.when_first_matching_example_defined(type: type) do
            config.before(:context) do
              unless ENV[env_var_name]
                yield
              end
              ENV[env_var_name] = 'hook_called'
            end
          end
        end
      end

      when_first_matching_example_defined(type: :model) do
        puts 'RSpec_custom_hook_called_once_for_model'
      end

      when_first_matching_example_defined(type: :system) do
        puts 'RSpec_custom_hook_called_once_for_system'
      end

      RSpec.configure do |config|
        config.before(:suite) do
          puts 'RSpec_before_suite_hook'
        end

        config.when_first_matching_example_defined(type: :model) do
          config.before(:suite) do
            puts 'RSpec_before_suite_hook_for_model'
          end
        end

        config.when_first_matching_example_defined(type: :system) do
          config.before(:suite) do
            puts 'RSpec_before_suite_hook_for_system'
          end
        end
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe', type: :model do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe', type: :system do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end

          it 'C1 test example', :model do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_d = Spec.new('d_spec.rb', <<~SPEC)
        describe 'D_describe', type: :system do
          it 'D1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a],
        [spec_b],
        [spec_c],
        [spec_d],
      ])

      actual = subject

      expect(actual.stdout.scan(/RSpec_before_suite_hook/).size).to eq 1

      # skips before(:suite) hooks that were defined too late in 1st & 2nd batch of tests after before(:suite) hook is already executed
      expect(actual.stdout.scan(/RSpec_before_suite_hook_for_model/).size).to eq 0
      expect(actual.stdout.scan(/RSpec_before_suite_hook_for_system/).size).to eq 0

      expect(actual.stdout.scan(/RSpec_custom_hook_called_once_for_model/).size).to eq 1
      expect(actual.stdout.scan(/RSpec_custom_hook_called_once_for_system/).size).to eq 1

      expect(actual.exit_code).to eq 0
    end

    it 'gives access to batch of tests in queue hooks' do
      rspec_options = ''

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      KnapsackPro::Hooks::Queue.before_subset_queue do |queue_id, subset_queue_id, queue|
        print "Tests in batches in before_subset_queue: "
        puts queue.map(&:test_file_paths).inspect

        print "Batches' statuses in before_subset_queue: "
        puts queue.map(&:status).inspect
      end

      KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id, queue|
        print "Tests in batches in after_subset_queue: "
        puts queue.map(&:test_file_paths).inspect
        print "Batches' statuses in after_subset_queue: "
        puts queue.map(&:status).inspect

        # call public API methods that must be backward compatible
        print "Current batch tests: "
        puts queue.current_batch.test_file_paths.inspect
        print "Current batch status: "
        puts queue.current_batch.status
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      failing_spec_d = Spec.new('d_spec.rb', <<~SPEC)
        describe 'D_describe' do
          it 'D1 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      spec_e = Spec.new('e_spec.rb', <<~SPEC)
        describe 'E_describe' do
          it 'E1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_f = Spec.new('f_spec.rb', <<~SPEC)
        describe 'F_describe' do
          it 'F1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      failing_spec_g = Spec.new('g_spec.rb', <<~SPEC)
        describe 'G_describe' do
          it 'G1 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      spec_h = Spec.new('h_spec.rb', <<~SPEC)
        describe 'h_describe' do
          it 'H1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b],
        [spec_c, failing_spec_d],
        [spec_e, spec_f],
        [failing_spec_g, spec_h],
      ])

      actual = subject

      expect(actual.stdout).to include('Tests in batches in before_subset_queue: [["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"]]')
      expect(actual.stdout).to include('Tests in batches in before_subset_queue: [["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"], ["spec_integration/c_spec.rb", "spec_integration/d_spec.rb"]]')
      expect(actual.stdout).to include('Tests in batches in before_subset_queue: [["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"], ["spec_integration/c_spec.rb", "spec_integration/d_spec.rb"], ["spec_integration/e_spec.rb", "spec_integration/f_spec.rb"]]')
      expect(actual.stdout).to include('Tests in batches in before_subset_queue: [["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"], ["spec_integration/c_spec.rb", "spec_integration/d_spec.rb"], ["spec_integration/e_spec.rb", "spec_integration/f_spec.rb"], ["spec_integration/g_spec.rb", "spec_integration/h_spec.rb"]]')

      expect(actual.stdout).to include('Tests in batches in after_subset_queue: [["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"]]')
      expect(actual.stdout).to include('Tests in batches in after_subset_queue: [["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"], ["spec_integration/c_spec.rb", "spec_integration/d_spec.rb"]]')
      expect(actual.stdout).to include('Tests in batches in after_subset_queue: [["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"], ["spec_integration/c_spec.rb", "spec_integration/d_spec.rb"], ["spec_integration/e_spec.rb", "spec_integration/f_spec.rb"]]')
      expect(actual.stdout).to include('Tests in batches in after_subset_queue: [["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"], ["spec_integration/c_spec.rb", "spec_integration/d_spec.rb"], ["spec_integration/e_spec.rb", "spec_integration/f_spec.rb"], ["spec_integration/g_spec.rb", "spec_integration/h_spec.rb"]]')


      expect(actual.stdout).to include("Batches' statuses in before_subset_queue: [:not_executed]")
      expect(actual.stdout).to include("Batches' statuses in before_subset_queue: [:passed, :not_executed]")
      expect(actual.stdout).to include("Batches' statuses in before_subset_queue: [:passed, :failed, :not_executed]")
      expect(actual.stdout).to include("Batches' statuses in before_subset_queue: [:passed, :failed, :passed, :not_executed]")

      expect(actual.stdout).to include("Batches' statuses in after_subset_queue: [:passed]")
      expect(actual.stdout).to include("Batches' statuses in after_subset_queue: [:passed, :failed]")
      expect(actual.stdout).to include("Batches' statuses in after_subset_queue: [:passed, :failed, :passed]")
      expect(actual.stdout).to include("Batches' statuses in after_subset_queue: [:passed, :failed, :passed, :failed]")

      expect(actual.stdout).to include('Current batch tests: ["spec_integration/a_spec.rb", "spec_integration/b_spec.rb"]')
      expect(actual.stdout).to include('Current batch tests: ["spec_integration/c_spec.rb", "spec_integration/d_spec.rb"]')
      expect(actual.stdout).to include('Current batch tests: ["spec_integration/e_spec.rb", "spec_integration/f_spec.rb"]')
      expect(actual.stdout).to include('Current batch tests: ["spec_integration/g_spec.rb", "spec_integration/h_spec.rb"]')
      expect(actual.stdout).to include('Current batch status: passed').twice
      expect(actual.stdout).to include('Current batch status: failed').twice

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when the RSpec seed is used' do
    it do
      rspec_options = '--order rand:123'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('Randomized with seed 123')

      # 1st batch
      expect(actual.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --order rand:123 --format progress --default-path spec_integration "spec_integration/a_spec.rb" "spec_integration/b_spec.rb"')
      # 2nd batch
      expect(actual.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --order rand:123 --format progress --default-path spec_integration "spec_integration/c_spec.rb"')

      # the final RSpec command with seed
      expect(actual.stdout).to include('INFO -- : [knapsack_pro] bundle exec rspec --order rand:123 --format progress --default-path spec_integration "spec_integration/a_spec.rb" "spec_integration/b_spec.rb" "spec_integration/c_spec.rb"')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when a failing test in a batch of tests that is not the last batch fetched from the Queue API' do
    it 'returns 1 as exit code (it remembers that one of the batches has a failing test)' do
      rspec_options = '--format documentation'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      failing_spec = Spec.new('failing_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, failing_spec],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('B1 test example (FAILED - 1)')
      expect(actual.stdout).to include('Failure/Error: expect(1).to eq 0')
      expect(actual.stdout).to include('3 examples, 1 failure')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when a failing test raises an exception' do
    it 'returns 1 as exit code AND the exception does not leak outside of the RSpec runner context' do
      rspec_options = '--format documentation'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      failing_spec = Spec.new('failing_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            raise 'A custom exception from a test'
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, failing_spec],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('B1 test example (FAILED - 1)')
      expect(actual.stdout).to include("Failure/Error: raise 'A custom exception from a test'")
      expect(actual.stdout).to include('3 examples, 1 failure')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when a spec file has a syntax error outside of the test example' do
    it 'stops running tests on the batch that has a test file with the syntax error AND returns 1 as exit code' do
      rspec_options = '--format documentation'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      failing_spec = Spec.new('failing_spec.rb', <<~SPEC)
        describe 'B_describe' do
          a_fake_method

          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a],
        [failing_spec],
        [spec_c],
      ])

      actual = subject

      # 1st batch of tests executed correctly
      expect(actual.stdout).to include('A1 test example')
      # 2nd batch contains the test file that cannot be loaded and the test file is not executed
      expect(actual.stdout).to_not include('B1 test example')
      # 3rd batch is never executed
      expect(actual.stdout).to_not include('C1 test example')

      expect(actual.stdout).to include('An error occurred while loading ./spec_integration/failing_spec.rb')
      expect(actual.stdout).to match(/undefined local variable or method `a_fake_method' for.* RSpec::ExampleGroups::BDescribe/)
      expect(actual.stdout).to include('WARN -- : [knapsack_pro] RSpec wants to quit')
      expect(actual.stdout).to include('1 example, 0 failures, 1 error occurred outside of examples')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when a syntax error (an exception) in spec_helper.rb' do
    it 'exits early with 1 as the exit code without running tests because RSpec wants to quit' do
      rspec_options = '--format documentation'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      a_fake_method
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a],
        [spec_b],
      ])

      actual = subject

      expect(actual.stdout).to include('An error occurred while loading spec_helper.')
      expect(actual.stdout).to include("undefined local variable or method `a_fake_method' for main")
      expect(actual.stdout).to include('0 examples, 0 failures, 1 error occurred outside of examples')

      expect(actual.exit_code).to eq 1
    end
  end

  # Based on:
  # https://github.com/rspec/rspec-core/pull/2926/files
  context 'when RSpec is quitting' do
    let(:helper_with_exit_location) { "#{SPEC_DIRECTORY}/helper_with_exit.rb" }

    it 'returns non zero exit code because RSpec is quitting' do
      skip 'Not supported by this RSpec version' if RSpec::Core::Version::STRING == '3.10.2'

      File.open(helper_with_exit_location, 'w') { |file| file.write('exit 123') }

      rspec_options = "--format documentation --require ./#{helper_with_exit_location}"

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a],
        [spec_b],
      ])

      actual = subject

      expect(actual.stdout).to include('While loading ./spec_integration/helper_with_exit.rb an `exit` / `raise SystemExit` occurred, RSpec will now quit.')

      expect(actual.stdout).to_not include('A1 test example')
      expect(actual.stdout).to_not include('B1 test example')

      expect(actual.exit_code).to eq 123
    end
  end

  context 'when the test suite has pending tests' do
    it 'shows the summary of pending tests' do
      rspec_options = '--format documentation'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          xit 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end

          xit 'C2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('B1 test example (PENDING: Temporarily skipped with xit)')
      expect(actual.stdout).to include('C2 test example (PENDING: Temporarily skipped with xit)')

      expect(actual.stdout).to include("Pending: (Failures listed here are expected and do not affect your suite's status)")
      expect(actual.stdout).to include('1) B_describe B1 test example')
      expect(actual.stdout).to include('2) C_describe C2 test example')

      expect(actual.stdout).to include('4 examples, 0 failures, 2 pending')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when a test file raises an exception that cannot be handle by RSpec' do
    it 'stops running tests when unhandled exception happens AND sets 1 as exit code AND shows summary of unexecuted tests' do
      rspec_options = '--format documentation'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      # list of unhandled exceptions:
      # RSpec::Support::AllExceptionsExceptOnesWeMustNotRescue::AVOID_RESCUING
      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            raise NoMemoryError.new
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a],
        [spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('A1 test example')

      expect(actual.stdout).to include('B_describe')
      expect(actual.stdout).to include('An unexpected exception happened. RSpec cannot handle it. The exception: #<NoMemoryError: NoMemoryError>')
      expect(actual.stdout).to include('Exception message: ')
      expect(actual.stdout).to include('Exception backtrace: ')
      expect(actual.stdout).to_not include('B1 test example')

      expect(actual.stdout).to_not include('C1 test example')

      # 2nd test example raised unhandled exception during runtime.
      # It breaks RSpec so it was not marked as failed.
      expect(actual.stdout).to include('2 examples, 0 failures')

      expect(actual.stdout).to include('WARN -- : [knapsack_pro] Unexecuted tests on this CI node (including pending tests): spec_integration/b_spec.rb')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when a test file raises an exception that cannot be handle by RSpec AND --error-exit-code is set' do
    it 'sets a custom exit code' do
      rspec_options = '--format documentation --error-exit-code 2'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            raise NoMemoryError.new
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a],
        [spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.exit_code).to eq 2
    end
  end

  context 'when a termination signal is received by the process' do
    it 'terminates the process after tests from the current RSpec ExampleGroup are executed and sets 1 as exit code' do
      rspec_options = '--format documentation'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B1_describe' do
          describe 'B1.1_describe' do
            xit 'B1.1.1 test example' do
              expect(1).to eq 1
            end
            it 'B1.1.2 test example' do
              Process.kill("INT", Process.pid)
            end
            it 'B1.1.3 test example' do
              expect(1).to eq 0
            end
          end

          describe 'B1.2_describe' do
            it 'B1.2.1 test example' do
              expect(1).to eq 1
            end
          end
        end

        describe 'B2_describe' do
          it 'B2.1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_d = Spec.new('d_spec.rb', <<~SPEC)
        describe 'D_describe' do
          it 'D1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a],
        [spec_b, spec_c],
        [spec_d],
      ])

      actual = subject

      expect(actual.stdout).to include('B1.1.1 test example (PENDING: Temporarily skipped with xit)')
      expect(actual.stdout).to include('INT signal has been received. Terminating Knapsack Pro...')
      expect(actual.stdout).to include('B1.1.2 test example')
      expect(actual.stdout).to include('B1.1.3 test example (FAILED - 1)')
      expect(actual.stdout).to include('B1.2.1 test example')

      # next ExampleGroup within the same b_spec.rb is not executed
      expect(actual.stdout).to_not include('B2.1 test example')

      # next test file from the same batch is not executed
      expect(actual.stdout).to_not include('C1 test example')

      # next batch of tests is not pulled from the Queue API and is not executed
      expect(actual.stdout).to_not include('D1 test example')


      expect(actual.stdout).to include(
        <<~OUTPUT
        Pending: (Failures listed here are expected and do not affect your suite's status)

          1) B1_describe B1.1_describe B1.1.1 test example
        OUTPUT
      )

      expect(actual.stdout).to include(
        <<~OUTPUT
        Failures:

          1) B1_describe B1.1_describe B1.1.3 test example
        OUTPUT
      )

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when a termination signal is received by the process AND --error-exit-code is set' do
    it 'terminates the process AND sets a custom exit code' do
      rspec_options = '--format documentation --error-exit-code 3'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            Process.kill("INT", Process.pid)
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a],
        [spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('INT signal has been received. Terminating Knapsack Pro...')

      expect(actual.exit_code).to eq 3
    end
  end

  context 'when deprecated run_all_when_everything_filtered option is true' do
    it 'shows an error message AND sets 1 as exit code' do
      rspec_options = '--format documentation'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.run_all_when_everything_filtered = true
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a],
        [spec_b],
      ])

      actual = subject

      expect(actual.stdout).to include('ERROR -- : [knapsack_pro] The run_all_when_everything_filtered option is deprecated. See: https://knapsackpro.com/perma/ruby/rspec-deprecated-run-all-when-everything-filtered')

      expect(actual.stdout).to_not include('A1 test example')
      expect(actual.stdout).to_not include('B1 test example')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when filter_run_when_matching is set to :focus and some tests are tagged with the focus tag' do
    it 'shows an error message for :focus tagged tests AND sets 1 as exit code (shows the error because the batch of tests that has no focus tagged tests will run tests instead of not running them)' do
      rspec_options = '--format documentation'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.filter_run_when_matching :focus
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example', :focus do
            expect(1).to eq 1
          end
          it 'B2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a],
        [spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('A1 test example')

      expect(actual.stdout).to include('B1 test example (FAILED - 1)')
      expect(actual.stdout).to_not include('B2 test example') # skips B2 test due to tagged B1

      expect(actual.stdout).to include('C1 test example')

      expect(actual.stdout).to include('Knapsack Pro found an example tagged with focus in spec_integration/b_spec.rb, please remove it. See more: https://knapsackpro.com/perma/ruby/rspec-skips-tests')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when the late CI node has an empty batch of tests because other CI nodes already consumed tests from the Queue API' do
    it 'sets 0 as exit code' do
      rspec_options = '--format documentation'

      generate_specs(spec_helper_with_knapsack, rspec_options, [])

      actual = subject

      expect(actual.stdout).to include('0 examples, 0 failures')
      expect(actual.stdout).to include('WARN -- : [knapsack_pro] No test files were executed on this CI node.')
      expect(actual.stdout).to include('DEBUG -- : [knapsack_pro] This CI node likely started work late after the test files were already executed by other CI nodes consuming the queue.')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when the fail_if_no_examples option is true AND the late CI node has an empty batch of tests because other CI nodes already consumed tests from the Queue API' do
    it 'sets 0 as exit code to ignore the fail_if_no_examples option' do
      rspec_options = '--format documentation'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.fail_if_no_examples = true
      end
      SPEC

      generate_specs(spec_helper, rspec_options, [])

      actual = subject

      expect(actual.stdout).to include('0 examples, 0 failures')
      expect(actual.stdout).to include('WARN -- : [knapsack_pro] No test files were executed on this CI node.')
      expect(actual.stdout).to include('DEBUG -- : [knapsack_pro] This CI node likely started work late after the test files were already executed by other CI nodes consuming the queue.')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when the fail_if_no_examples option is true AND a batch of tests has a test file without test examples' do
    it 'sets 0 as exit code to ignore the fail_if_no_examples option' do
      rspec_options = '--format documentation'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.fail_if_no_examples = true
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b_with_no_examples = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a],
        [spec_b_with_no_examples],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('2 examples, 0 failures')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when tests are failing AND --failure-exit-code is set' do
    it 'returns a custom exit code' do
      rspec_options = '--format documentation --failure-exit-code 4'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      failing_spec = Spec.new('failing_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, failing_spec],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('B1 test example (FAILED - 1)')
      expect(actual.stdout).to include('Failure/Error: expect(1).to eq 0')
      expect(actual.stdout).to include('3 examples, 1 failure')

      expect(actual.exit_code).to eq 4
    end
  end

  context 'when --profile is set' do
    it 'shows top slowest examples AND top slowest example groups' do
      rspec_options = '--format d --profile'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('Top 3 slowest examples')
      expect(actual.stdout).to include('A_describe A1 test example')
      expect(actual.stdout).to include('B_describe B1 test example')
      expect(actual.stdout).to include('C_describe C1 test example')

      expect(actual.stdout).to include('Top 3 slowest example groups')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when an invalid RSpec option is set' do
    it 'returns 1 as exit code AND shows an error message to stderr' do
      rspec_options = '--format d --fake-rspec-option'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a],
        [spec_b],
      ])

      actual = subject

      expect(actual.stderr).to include('invalid option: --fake-rspec-option')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when --fail-fast is set' do
    it 'stops running tests on the failing test AND returns 1 as exit code AND shows a warning message' do
      rspec_options = '--format d --fail-fast'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
          it 'C2 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('A1 test example')
      expect(actual.stdout).to include('B1 test example')
      expect(actual.stdout).to_not include('C1 test example')
      expect(actual.stdout).to_not include('C2 test example')

      expect(actual.stdout).to include('WARN -- : [knapsack_pro] Test execution has been canceled because the RSpec --fail-fast option is enabled. It will cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')

      expect(actual.stdout).to include('2 examples, 1 failure')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when the fail_fast option is set with a specific number of tests' do
    it 'stops running tests on the 2nd failing test AND returns 1 as exit code AND shows a warning message when fail fast limit met' do
      rspec_options = '--format d'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.fail_fast = 2
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
          it 'B2 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
          it 'C2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('A1 test example (FAILED - 1)')
      expect(actual.stdout).to include('B1 test example')
      expect(actual.stdout).to include('B2 test example (FAILED - 2)')
      expect(actual.stdout).to_not include('C1 test example')
      expect(actual.stdout).to_not include('C2 test example')

      expect(actual.stdout).to include('WARN -- : [knapsack_pro] Test execution has been canceled because the RSpec --fail-fast option is enabled. It will cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')

      expect(actual.stdout).to include('3 examples, 2 failures')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when --tag is set' do
    it 'runs only tagged test examples from multiple batches of tests fetched from the Queue API' do
      rspec_options = '--format d --tag my_tag'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
          it 'A2 test example', :my_tag do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe', :my_tag do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_d = Spec.new('d_spec.rb', <<~SPEC)
        describe 'D_describe' do
          it 'D1 test example' do
            expect(1).to eq 1
          end
          it 'D2 test example', :my_tag do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
        [spec_d],
      ])

      actual = subject

      expect(actual.stdout).to_not include('A1 test example')
      expect(actual.stdout).to include('A2 test example')

      expect(actual.stdout).to include('B1 test example')

      expect(actual.stdout).to_not include('C1 test example')

      expect(actual.stdout).to_not include('D1 test example')
      expect(actual.stdout).to include('D2 test example')

      expect(actual.stdout).to include('3 examples, 0 failures')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when the RSpec split by examples is enabled' do
    before do
      ENV['KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES'] = 'true'

      # remember to stub Queue API batches to include test examples (example: a_spec.rb[1:1])
      # for the following slow test files
      ENV['KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN'] = "#{SPEC_DIRECTORY}/a_spec.rb"
    end
    after do
      ENV.delete('KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES')
      ENV.delete('KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN')
    end

    it 'splits slow test files by examples AND ensures the test examples are executed only once' do
      rspec_options = '--format d'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
          it 'A2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
          it 'B2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
          it 'C2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b, spec_c]
      ])
      stub_test_cases_for_slow_test_files([
        "#{spec_a.path}[1:1]",
        "#{spec_a.path}[1:2]",
      ])
      stub_spec_batches([
        ["#{spec_a.path}[1:1]", spec_b.path],
        ["#{spec_a.path}[1:2]", spec_c.path],
      ])

      actual = subject

      expect(actual.stdout).to include('DEBUG -- : [knapsack_pro] Detected 1 slow test files: [{"path"=>"spec_integration/a_spec.rb"}]')

      expect(actual.stdout).to include(
        <<~OUTPUT
        A_describe
          A1 test example

        B_describe
          B1 test example
          B2 test example
        OUTPUT
      )

      expect(actual.stdout).to include(
        <<~OUTPUT
        A_describe
          A2 test example

        C_describe
          C1 test example
          C2 test example
        OUTPUT
      )

      expect(actual.stdout.scan(/A1 test example/).size).to eq 1
      expect(actual.stdout.scan(/A2 test example/).size).to eq 1

      expect(actual.stdout).to include('6 examples, 0 failures')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when the RSpec split by examples is enabled AND --tag is set' do
    before do
      ENV['KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES'] = 'true'

      # remember to stub Queue API batches to include test examples (example: a_spec.rb[1:1])
      # for the following slow test files
      ENV['KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN'] = "#{SPEC_DIRECTORY}/a_spec.rb"
    end
    after do
      ENV.delete('KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES')
      ENV.delete('KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN')
    end

    it 'sets 1 as exit code AND raises an error (a test example path as a_spec.rb[1:1] would always be executed even when it does not have the tag that is set via the --tag option. We cannot run tests because it could lead to running unintentional tests)' do
      rspec_options = '--format d --tag my_tag'

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
          it 'A2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe', :my_tag do
          it 'B1 test example' do
            expect(1).to eq 1
          end
          it 'B2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
          it 'C2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b, spec_c]
      ])
      stub_test_cases_for_slow_test_files([
        "#{spec_a.path}[1:1]",
        "#{spec_a.path}[1:2]",
      ])
      stub_spec_batches([
        ["#{spec_a.path}[1:1]", spec_b.path],
        ["#{spec_a.path}[1:2]", spec_c.path],
      ])

      actual = subject

      expect(actual.stdout).to include('ERROR -- : [knapsack_pro] It is not allowed to use the RSpec tag option together with the RSpec split by test examples feature. Please see: https://knapsackpro.com/perma/ruby/rspec-split-by-test-examples-tag')

      expect(actual.stdout).to_not include('A1 test example')
      expect(actual.stdout).to_not include('A2 test example')
      expect(actual.stdout).to_not include('B1 test example')
      expect(actual.stdout).to_not include('B2 test example')
      expect(actual.stdout).to_not include('C1 test example')
      expect(actual.stdout).to_not include('C2 test example')

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when the RSpec split by examples is enabled AND JSON formatter is used' do
    let(:json_file) { "#{SPEC_DIRECTORY}/rspec.json" }

    before do
      ENV['KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES'] = 'true'

      # remember to stub Queue API batches to include test examples (example: a_spec.rb[1:1])
      # for the following slow test files
      ENV['KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN'] = "#{SPEC_DIRECTORY}/a_spec.rb"
    end
    after do
      ENV.delete('KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES')
      ENV.delete('KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN')
    end

    it 'produces a JSON report' do
      rspec_options = "--format documentation --format json --out ./#{json_file}"

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
          it 'A2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
          it 'B2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
          it 'C2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b, spec_c]
      ])
      stub_test_cases_for_slow_test_files([
        "#{spec_a.path}[1:1]",
        "#{spec_a.path}[1:2]",
      ])
      stub_spec_batches([
        ["#{spec_a.path}[1:1]", spec_b.path],
        ["#{spec_a.path}[1:2]", spec_c.path],
      ])

      actual = subject

      file_content = File.read(json_file)
      json = JSON.load(file_content)
      examples = json.fetch('examples')

      example_ids = examples.map do
        _1.fetch('id')
      end
      expect(example_ids).to match_array([
        './spec_integration/a_spec.rb[1:1]',
        './spec_integration/b_spec.rb[1:1]',
        './spec_integration/b_spec.rb[1:2]',
        './spec_integration/a_spec.rb[1:2]',
        './spec_integration/c_spec.rb[1:1]',
        './spec_integration/c_spec.rb[1:2]'
      ])

      example_full_descriptions = examples.map do
        _1.fetch('full_description')
      end
      expect(example_full_descriptions).to match_array([
        'A_describe A1 test example',
        'B_describe B1 test example',
        'B_describe B2 test example',
        'A_describe A2 test example',
        'C_describe C1 test example',
        'C_describe C2 test example'
      ])

      expect(json.fetch('summary_line')).to eq '6 examples, 0 failures'

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when the RSpec split by examples is enabled AND JUnit XML formatter is used' do
    let(:xml_file) { "#{SPEC_DIRECTORY}/rspec.xml" }

    before do
      ENV['KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES'] = 'true'

      # remember to stub Queue API batches to include test examples (example: a_spec.rb[1:1])
      # for the following slow test files
      ENV['KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN'] = "#{SPEC_DIRECTORY}/a_spec.rb"
    end
    after do
      ENV.delete('KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES')
      ENV.delete('KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN')
    end

    it 'produces a JUnit XML report' do
      rspec_options = "--format documentation --format RspecJunitFormatter --out ./#{xml_file}"

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
          it 'A2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
          it 'B2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
          it 'C2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a, spec_b, spec_c]
      ])
      stub_test_cases_for_slow_test_files([
        "#{spec_a.path}[1:1]",
        "#{spec_a.path}[1:2]",
      ])
      stub_spec_batches([
        ["#{spec_a.path}[1:1]", spec_b.path],
        ["#{spec_a.path}[1:2]", spec_c.path],
      ])

      actual = subject

      file_content = File.read(xml_file)
      doc = Nokogiri::XML(file_content)

      files = doc.xpath('//testcase').map do |testcase|
        testcase['file']
      end
      expect(files).to eq([
        './spec_integration/a_spec.rb',
        './spec_integration/b_spec.rb',
        './spec_integration/b_spec.rb',
        './spec_integration/a_spec.rb',
        './spec_integration/c_spec.rb',
        './spec_integration/c_spec.rb',
      ])

      examples = doc.xpath('//testcase').map do |testcase|
        testcase['name']
      end
      expect(examples).to eq([
        'A_describe A1 test example',
        'B_describe B1 test example',
        'B_describe B2 test example',
        'A_describe A2 test example',
        'C_describe C1 test example',
        'C_describe C2 test example',
      ])

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when the RSpec split by examples is enabled AND simplecov is used' do
    let(:coverage_dir) { "#{KNAPSACK_PRO_TMP_DIR}/coverage" }
    let(:coverage_file) { "#{coverage_dir}/index.html" }

    before do
      ENV['KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES'] = 'true'

      # remember to stub Queue API batches to include test examples (example: a_spec.rb[1:1])
      # for the following slow test files
      ENV['KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN'] = "#{SPEC_DIRECTORY}/a_spec.rb"
    end
    after do
      ENV.delete('KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES')
      ENV.delete('KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN')
    end

    it 'produces a code coverage report' do
      rspec_options = '--format documentation'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      require 'simplecov'
      SimpleCov.start do
        coverage_dir '#{coverage_dir}'
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
          it 'A2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
          it 'B2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
          it 'C2 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b, spec_c]
      ])
      stub_test_cases_for_slow_test_files([
        "#{spec_a.path}[1:1]",
        "#{spec_a.path}[1:2]",
      ])
      stub_spec_batches([
        ["#{spec_a.path}[1:1]", spec_b.path],
        ["#{spec_a.path}[1:2]", spec_c.path],
      ])

      actual = subject

      file_content = File.read(coverage_file)

      expect(file_content).to include(spec_a.path)
      expect(file_content).to include(spec_b.path)
      expect(file_content).to include(spec_c.path)

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when the example_status_persistence_file_path option is used and multiple batches of tests are fetched from the Queue API and some tests are pending and failing' do
    let(:examples_file_path) { "#{SPEC_DIRECTORY}/examples.txt" }

    after do
      File.delete(examples_file_path) if File.exist?(examples_file_path)
    end

    it 'runs tests AND creates the example status persistence file' do
      rspec_options = '--format d'

      spec_helper = <<~SPEC
      require 'knapsack_pro'
      KnapsackPro::Adapters::RSpecAdapter.bind

      RSpec.configure do |config|
        config.example_status_persistence_file_path = '#{examples_file_path}'
      end
      SPEC

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          xit 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      spec_c = Spec.new('c_spec.rb', <<~SPEC)
        describe 'C_describe' do
          it 'C1 test example' do
            expect(1).to eq 1
          end
          it 'C2 test example' do
            expect(1).to eq 0
          end
        end
      SPEC

      generate_specs(spec_helper, rspec_options, [
        [spec_a, spec_b],
        [spec_c],
      ])

      actual = subject

      expect(actual.stdout).to include('4 examples, 2 failures, 1 pending')

      expect(File.exist?(examples_file_path)).to be true

      examples_file_content = File.read(examples_file_path)

      expect(examples_file_content).to include './spec_integration/a_spec.rb[1:1] | pending'
      expect(examples_file_content).to include './spec_integration/b_spec.rb[1:1] | failed'
      expect(examples_file_content).to include './spec_integration/c_spec.rb[1:1] | passed'
      expect(examples_file_content).to include './spec_integration/c_spec.rb[1:2] | failed'

      expect(actual.exit_code).to eq 1
    end
  end

  context 'when the .rspec file has RSpec options' do
    let(:dot_rspec_file) { "#{SPEC_DIRECTORY}/.rspec" }

    it 'ignores options from the .rspec file' do
      File.open(dot_rspec_file, 'w') { |file| file.write('--format documentation') }

      rspec_options = ''

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a],
      ])

      actual = subject

      expect(actual.stdout).not_to include('A1 test example')

      expect(actual.stdout).to include('1 example, 0 failures')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when --options is set' do
    let(:rspec_custom_options_file) { "#{SPEC_DIRECTORY}/.rspec_custom_options" }

    it 'uses options from the custom rspec file' do
      rspec_custom_options = <<~FILE
      --require spec_helper
      --profile
      FILE
      File.open(rspec_custom_options_file, 'w') { |file| file.write(rspec_custom_options) }

      rspec_options = "--options ./#{rspec_custom_options_file}"

      spec_a = Spec.new('a_spec.rb', <<~SPEC)
        describe 'A_describe' do
          it 'A1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      spec_b = Spec.new('b_spec.rb', <<~SPEC)
        describe 'B_describe' do
          it 'B1 test example' do
            expect(1).to eq 1
          end
        end
      SPEC

      generate_specs(spec_helper_with_knapsack, rspec_options, [
        [spec_a],
        [spec_b],
      ])

      actual = subject

      expect(actual.stdout).to include('2 examples, 0 failures')

      expect(actual.stdout).to include('Top 2 slowest example groups')

      expect(actual.exit_code).to eq 0
    end
  end

  context 'when rspec is run without knapsack_pro' do
    let(:spec) { Spec.new('a_spec.rb', <<~SPEC) }
      require_relative "spec_helper.rb"

      describe 'A_describe' do
        it 'A1 test example' do
          expect(1).to eq 1
        end
      end
    SPEC

    let(:command) { "bundle exec rspec #{spec.path}" }

    it 'runs successfully' do
      generate_spec_helper(spec_helper_with_knapsack)
      generate_spec_files([spec])

      actual = subject

      expect(actual.stdout).to include('1 example, 0 failures')
      expect(actual.exit_code).to eq 0
    end
  end
end
