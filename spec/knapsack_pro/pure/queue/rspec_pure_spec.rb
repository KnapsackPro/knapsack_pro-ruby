require(KnapsackPro.root + '/lib/knapsack_pro/formatters/time_tracker')
require(KnapsackPro.root + '/lib/knapsack_pro/extensions/rspec_extension')

describe KnapsackPro::Pure::Queue::RSpecPure do
  let(:adapter_class) { KnapsackPro::Adapters::RSpecAdapter }
  let(:time_tracker_fetcher) { KnapsackPro::Formatters::TimeTrackerFetcher }

  let(:rspec_pure) { described_class.new(adapter_class) }

  before do
  end

  describe '#add_knapsack_pro_formatters_to' do
    subject { rspec_pure.add_knapsack_pro_formatters_to(spec_opts) }

    context 'when no spec_opts' do
      let(:spec_opts) { nil }

      it 'returns no spec_opts' do
        expect(subject).to be nil
      end
    end

    context 'when spec_opts have Knapsack Pro formatters' do
      let(:spec_opts) { '--color --format d --format KnapsackPro::Formatters::TimeTracker' }

      it 'returns spec_opts' do
        expect(subject).to eq spec_opts
      end
    end

    context 'when spec_opts have no Knapsack Pro formatters' do
      let(:spec_opts) { '--color --format d' }

      it 'returns spec_opts with added Knapsack Pro formatters' do
        expect(subject).to eq '--color --format d --format KnapsackPro::Formatters::TimeTracker'
      end
    end
  end

  describe '#error_exit_code' do
    subject { rspec_pure.error_exit_code(rspec_error_exit_code) }

    context 'when RSpec has no defined error exit code' do
      let(:rspec_error_exit_code) { nil }

      it 'returns 1 as the default exit code' do
        expect(subject).to eq 1
      end
    end

    context 'when RSpec has a defined error exit code' do
      let(:rspec_error_exit_code) { 2 }

      it 'returns the custom exit code' do
        expect(subject).to eq rspec_error_exit_code
      end
    end
  end

  describe '#args_with_seed_option_added_when_viable' do
    let(:seed) { KnapsackPro::Extensions::RSpecExtension::Seed.new(seed_value, is_seed_used) }

    subject { rspec_pure.args_with_seed_option_added_when_viable(seed, args) }

    context 'when the order option is not random' do
      let(:args) { ['--order', 'defined'] }
      let(:is_seed_used) { false }
      let(:seed_value) { nil }

      it 'does not add the seed option to args' do
        expect(subject).to eq ['--order', 'defined']
      end
    end

    ['random', 'rand'].each do |random_option_value|
      context "when the order option is `#{random_option_value}`" do
        let(:args) { ['--order', random_option_value] }

        context 'when the seed is not used' do
          let(:is_seed_used) { false }
          let(:seed_value) { '123' }

          it 'does not add the seed option to args' do
            expect(subject).to eq ['--order', random_option_value]
          end
        end

        context 'when the seed is used' do
          let(:is_seed_used) { true }
          let(:seed_value) { '123' }

          it 'adds the seed option to args' do
            expect(subject).to eq ['--order', random_option_value, '--seed', '123']
          end
        end
      end
    end

    context 'when the order option is `rand:123`' do
      let(:args) { ['--order', 'rand:123'] }
      let(:is_seed_used) { true }
      let(:seed_value) { '123' }

      it 'does not add the seed option to args' do
        expect(subject).to eq ['--order', 'rand:123']
      end
    end

    context 'when the order option is not set in args AND seed is used' do
      let(:args) { ['--format', 'documentation'] }
      let(:is_seed_used) { true }
      let(:seed_value) { '123' }

      it 'adds the seed option to args' do
        expect(subject).to eq ['--format', 'documentation', '--seed', '123']
      end
    end

    context 'when the order option is not set in args AND seed is not used' do
      let(:args) { ['--format', 'documentation'] }
      let(:is_seed_used) { false }
      let(:seed_value) { '123' }

      it 'does not add the seed option to args' do
        expect(subject).to eq ['--format', 'documentation']
      end
    end
  end

  describe '#prepare_cli_args' do
    subject { rspec_pure.prepare_cli_args(args, test_dir) }

    context 'when no args' do
      let(:args) { nil }
      let(:test_dir) { 'spec' }

      it 'adds the default progress formatter and the default path and the time tracker formatter' do
        expect(subject).to eq [
          '--format', 'progress',
          '--default-path', 'spec',
          '--format', 'KnapsackPro::Formatters::TimeTracker',
        ]
      end
    end

    context 'when args are present and a custom test directory is set' do
      let(:args) { '--color --profile' }
      let(:test_dir) { 'custom_spec_dir' }

      it do
        expect(subject).to eq [
          '--color',
          '--profile',
          '--format', 'progress',
          '--default-path', 'custom_spec_dir',
          '--format', 'KnapsackPro::Formatters::TimeTracker',
        ]
      end
    end

    context 'when args are present and the format option is present' do
      let(:args) { '--color --profile --format d' }
      let(:test_dir) { 'spec' }

      it 'uses the format option instead of the default formatter' do
        expect(subject).to eq [
          '--color',
          '--profile',
          '--format', 'd',
          '--default-path', 'spec',
          '--format', 'KnapsackPro::Formatters::TimeTracker',
        ]
      end
    end
  end

  describe '#rspec_command' do
    let(:args) { ['--format', 'documentation'] }
    let(:test_file_paths) { ['a_spec.rb', 'b_spec.rb'] }

    subject { rspec_pure.rspec_command(args, test_file_paths, scope) }

    context 'when there are no test file paths' do
      let(:scope) { :queue_finished }
      let(:test_file_paths) { [] }

      it 'returns no messages' do
        expect(subject).to eq []
      end
    end

    context 'when a subset of queue (a batch of tests fetched from the Queue API)' do
      let(:scope) { :batch_finished }

      it 'returns messages with the RSpec command' do
        expect(subject).to eq([
          'To retry the last batch of tests fetched from the Queue API, please run the following command on your machine:',
          'bundle exec rspec --format documentation "a_spec.rb" "b_spec.rb"',
        ])
      end
    end

    context 'when all tests fetched from the Queue API' do
      let(:scope) { :queue_finished }

      it 'returns messages with the RSpec command' do
        expect(subject).to eq([
          'To retry all the tests assigned to this CI node, please run the following command on your machine:',
          'bundle exec rspec --format documentation "a_spec.rb" "b_spec.rb"',
        ])
      end
    end

    describe '#exit_summary' do
      let(:node_test_file_paths) { ['a_spec.rb', 'b_spec.rb', 'c_spec.rb'] }

      subject { rspec_pure.exit_summary(node_test_file_paths) }

      before do
        expect(time_tracker_fetcher).to receive(:call).and_return(time_tracker)
      end

      context 'when the KnapsackPro::Formatters::TimeTracker formatter is not found' do
        let(:time_tracker) { nil }

        it { expect(subject).to be_nil }
      end

      context 'when the KnapsackPro::Formatters::TimeTracker formatter is found' do
        let(:time_tracker) { instance_double(KnapsackPro::Formatters::TimeTracker) }

        before do
          expect(time_tracker).to receive(:unexecuted_test_files).with(node_test_file_paths).and_return(unexecuted_test_files)
        end

        context 'when there are no unexecuted test files' do
          let(:unexecuted_test_files) { [] }

          it { expect(subject).to be_nil }
        end

        context 'when there are unexecuted test files' do
          let(:unexecuted_test_files) { ['b_spec.rb', 'c_spec.rb'] }

          it 'returns a warning' do
            expect(subject).to eq 'Unexecuted tests on this CI node (including pending tests): b_spec.rb c_spec.rb'
          end
        end
      end
    end
  end
end
