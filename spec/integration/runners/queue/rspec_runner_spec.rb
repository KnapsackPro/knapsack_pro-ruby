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

  context 'context' do
    it do
      spec_a = SpecItem.new(
        'a_spec.rb',
        <<~SPEC
        describe "A" do
          it 'test case' do
            expect(1).to eq 1
          end
        end
        SPEC
      )

      rspec_options = '--format d'
      run_specs(spec_helper_with_knapsack, rspec_options, [spec_a]) do
        mock_batched_tests([
          [spec_a.path],
        ])

        result = subject

        expect(result.exit_code).to eq 0
      end
    end
  end
end
