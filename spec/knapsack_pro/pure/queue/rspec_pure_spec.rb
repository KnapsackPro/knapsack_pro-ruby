require(KnapsackPro.root + '/lib/knapsack_pro/formatters/time_tracker')
require(KnapsackPro.root + '/lib/knapsack_pro/extensions/rspec_extension')

describe KnapsackPro::Pure::Queue::RSpecPure do
  let(:rspec_pure) { described_class.new }

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
    let(:order_option) { KnapsackPro::Adapters::RSpecAdapter.order_option(args) }

    subject { rspec_pure.args_with_seed_option_added_when_viable(order_option, seed, args) }

    context 'when the order option is not random' do
      let(:args) { ['--order', 'defined'] }
      let(:seed) { KnapsackPro::Extensions::RSpecExtension::Seed.new(value: nil, used?: false) }

      it 'does not add the seed option to args' do
        expect(subject).to eq ['--order', 'defined']
      end
    end

    ['random', 'rand'].each do |random_option_value|
      context "when the order option is `#{random_option_value}`" do
        let(:args) { ['--order', random_option_value] }

        context 'when the seed is not used' do
          let(:seed) { KnapsackPro::Extensions::RSpecExtension::Seed.new(value: '123', used?: false) }

          it 'does not add the seed option to args' do
            expect(subject).to eq ['--order', random_option_value]
          end
        end

        context 'when the seed is used' do
          let(:seed) { KnapsackPro::Extensions::RSpecExtension::Seed.new(value: '123', used?: true) }

          it 'adds the seed option to args' do
            expect(subject).to eq ['--order', random_option_value, '--seed', '123']
          end
        end
      end
    end

    context 'when the order option is `rand:123`' do
      let(:args) { ['--order', 'rand:123'] }
      let(:seed) { KnapsackPro::Extensions::RSpecExtension::Seed.new(value: '123', used?: true) }

      it 'does not add the seed option to args' do
        expect(subject).to eq ['--order', 'rand:123']
      end
    end

    context 'when the order option is not set in args AND seed is used' do
      let(:args) { ['--format', 'documentation'] }
      let(:seed) { KnapsackPro::Extensions::RSpecExtension::Seed.new(value: '123', used?: true) }

      it 'adds the seed option to args' do
        expect(subject).to eq ['--format', 'documentation', '--seed', '123']
      end
    end

    context 'when the order option is not set in args AND seed is not used' do
      let(:args) { ['--format', 'documentation'] }
      let(:seed) { KnapsackPro::Extensions::RSpecExtension::Seed.new(value: '123', used?: false) }

      it 'does not add the seed option to args' do
        expect(subject).to eq ['--format', 'documentation']
      end
    end
  end

  describe '#prepare_cli_args' do
    subject { rspec_pure.prepare_cli_args(args, has_format_option, has_require_rails_helper_option, rails_helper_exists, test_dir) }

    context 'when no args' do
      let(:args) { nil }
      let(:has_format_option) { false }
      let(:has_require_rails_helper_option) { false }
      let(:test_dir) { 'spec' }

      context 'when rails_helper does not exist' do
        let(:rails_helper_exists) { false }

        it 'adds the default progress formatter, the default path and the time tracker formatter, does not add require rails_helper' do
          expect(subject).to eq [
            '--format', 'progress',
            '--default-path', 'spec',
            '--format', 'KnapsackPro::Formatters::TimeTracker',
          ]
        end
      end

      context 'when rails_helper exists' do
        let(:rails_helper_exists) { true }

        it 'adds the default progress formatter, require rails_helper, the default path and the time tracker formatter' do
          expect(subject).to eq [
            '--format', 'progress',
            '--require', 'rails_helper',
            '--default-path', 'spec',
            '--format', 'KnapsackPro::Formatters::TimeTracker',
          ]
        end
      end
    end

    context 'when args are present and a custom test directory is set' do
      let(:args) { '--color --profile --require rails_helper' }
      let(:has_format_option) { false }
      let(:has_require_rails_helper_option) { true }
      let(:rails_helper_exists) { true }
      let(:test_dir) { 'custom_spec_dir' }

      it do
        expect(subject).to eq [
          '--color',
          '--profile',
          '--require', 'rails_helper',
          '--format', 'progress',
          '--default-path', 'custom_spec_dir',
          '--format', 'KnapsackPro::Formatters::TimeTracker',
        ]
      end
    end

    context 'when args are present and has format option' do
      let(:args) { '--color --profile --format d --require rails_helper' }
      let(:has_format_option) { true }
      let(:has_require_rails_helper_option) { true }
      let(:rails_helper_exists) { true }
      let(:test_dir) { 'spec' }

      it 'uses the format option from args instead of the default formatter' do
        expect(subject).to eq [
          '--color',
          '--profile',
          '--format', 'd',
          '--require', 'rails_helper',
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
      subject { rspec_pure.exit_summary(unexecuted_test_files) }

      context 'when there are no unexecuted test files' do
        let(:unexecuted_test_files) { [] }

        it { expect(subject).to be_nil }
      end

      context 'when there are unexecuted test files' do
        let(:unexecuted_test_files) { ['b_spec.rb', 'c_spec.rb'] }

        it 'returns a warning message' do
          expect(subject).to eq 'Unexecuted tests on this CI node (including pending tests): b_spec.rb c_spec.rb'
        end
      end
    end
  end
end
