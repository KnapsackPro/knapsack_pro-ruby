require 'open3'
require 'json'

describe "#{KnapsackPro::Runners::Queue::RSpecRunner} - Integration tests" do
  # @param rspec_options String
  def run_specs(spec_helper_content, rspec_options, specs)
    ENV['TEST__RSPEC_OPTIONS'] = rspec_options

    spec_helper_path = 'spec_integration/spec_helper.rb'
    File.open(spec_helper_path, 'w') { |file| file.write(spec_helper_content) }

    paths = Array(specs).map.with_index do |spec, i|
      path = "spec_integration/#{i}_#{SecureRandom.uuid}_spec.rb"
      File.open(path, 'w') { |file| file.write(spec) }
      path
    end

    yield paths
  ensure
    File.delete(spec_helper_path)
    paths.each { |path| File.delete(path) }
  end

  let(:spec_helper_with_knapsack) do
    <<~SPEC
    require 'knapsack_pro'

    KnapsackPro::Adapters::RSpecAdapter.bind
    SPEC
  end

  subject do
    command = 'ruby spec_integration/queue_runner.rb'
    Open3.capture3(command)
  end

  before do
    ENV['TEST__SHOW_DEBUG_LOG'] = 'true'
  end

  context 'context' do
    it do
      spec_1 = <<~SPEC
        describe "A" do
          it 'test case' do
            expect(1).to eq 1
          end
        end
      SPEC

      rspec_options = '--format d'
      run_specs(spec_helper_with_knapsack, rspec_options, [spec_1]) do |paths|
        ENV['MOCK_BATCHED_TESTS'] = [
          [paths[0]],
        ].to_json

        stdout, stderr, status = subject

        if ENV['TEST__SHOW_DEBUG_LOG']
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

        expect(status.exitstatus).to eq 0
      end
    end
  end
end
