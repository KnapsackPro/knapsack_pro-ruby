describe "#{KnapsackPro::Runners::Queue::RSpecRunner} - Integration tests" do
  module Extensions
    def self.setup!
      KnapsackPro::QueueAllocator.prepend(QueueAllocatorExtension)
    end

    module QueueAllocatorExtension
      BATCHED_TEST = []
      def test_file_paths(can_initialize_queue, executed_test_files)
        return super if ENV['MOCK_QUEUE_API_BATCHED_TESTS'] != 'true'

        @@index ||= 0
        batches = Extensions::QueueAllocatorExtension::BATCHED_TESTS + [
          #['spec/features/calculator_spec.rb[1:2:1]', 'spec/controllers/articles_controller_spec.rb'],
          #['spec/collection_spec.rb'],
          #['spec/features/calculator_spec.rb[1:1:1]'],
          #['spec/bar_spec.rb'],
          [], # the last Queue API response is always the empty list of test files
        ]
        #batches = [
        #[]
        #]
        tests = batches[@@index] || []
        @@index += 1
        puts '='*50
        puts 'Tests (mocked API response):'
        puts tests.inspect
        puts '='*50
        return tests
      end
    end
  end

  def run_specs(specs)
    paths = Array(specs).map.with_index do |spec, i|
      path = "spec_integration/queue_rspec_#{i}_#{SecureRandom.uuid}_spec.rb"
      File.open(path, 'w') { |file| file.write(spec) }
      path
    end

    yield paths
  ensure
    paths.each { |path| File.delete(path) }
  end

  subject { KnapsackPro::Runners::Queue::RSpecRunner.run(args) }

  before do
    Extensions.setup!

    ENV['KNAPSACK_PRO_CI_NODE_BUILD_ID'] = SecureRandom.uuid
    ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC'] = 'fec3c641a3c4d2e720fe1b6d9dd780bc'
    ENV['MOCK_QUEUE_API_BATCHED_TESTS'] = 'true'
    ENV['KNAPSACK_PRO_TEST_DIR'] = 'spec_integration'
  end

  context 'context' do
    let(:args) { '--format d --require spec_helper' }

    it do
      #subject

      expect(KnapsackPro::Report).to receive(:create_build_subset)

      spec_1 = <<~SPEC
        require_relative 'spec_helper'

        describe "A" do
          it 'test case' do
            expect(1).to eq 1
          end
        end
      SPEC

      run_specs([spec_1]) do |paths|
        puts 'INSIDE'

        stub_const('Extensions::QueueAllocatorExtension::BATCHED_TESTS', [
          [paths[0]]
        ])

        subject
      end
    end
  end
end
