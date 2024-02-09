describe KnapsackPro::Runners::Queue::RSpecRunner do
  before do
    require KnapsackPro.root + '/lib/knapsack_pro/formatters/time_tracker'
  end

  describe described_class::FunctionalCore do
    let(:logger) { instance_double(::Logger) }
    let(:function_core) { described_class.new(logger) }

    describe '#ensure_no_deprecated_run_all_when_everything_filtered_option!' do
      subject { function_core.ensure_no_deprecated_run_all_when_everything_filtered_option!(deprecated_run_all_when_everything_filtered_enabled) }

      context 'when `run_all_when_everything_filtered_enabled` is enabled' do
        let(:deprecated_run_all_when_everything_filtered_enabled) { true }

        it do
          error_message = 'The run_all_when_everything_filtered option is deprecated. See: https://knapsackpro.com/perma/ruby/rspec-deprecated-run-all-when-everything-filtered'
          expect(logger).to receive(:error).with(error_message)
          expect { subject }.to raise_error error_message
        end
      end

      context 'when `run_all_when_everything_filtered_enabled` is disabled' do
        let(:deprecated_run_all_when_everything_filtered_enabled) { false }

        it do
          expect { subject }.not_to raise_error
        end
      end
    end

    describe '#ensure_spec_opts_have_knapsack_pro_formatters' do
      subject { function_core.ensure_spec_opts_have_knapsack_pro_formatters(spec_opts) }

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

    describe '#set_error_exit_code' do
      subject { function_core.set_error_exit_code(rspec_error_exit_code) }

      context 'when RSpec has no defined error exit code' do
        let(:rspec_error_exit_code) { nil }

        it 'sets 1 as the default exit code' do
          expect(Kernel).to receive(:exit).with(1)
          subject
        end
      end

      context 'when RSpec has a defined error exit code' do
        let(:rspec_error_exit_code) { 2 }

        it 'sets the custom exit code' do
          expect(Kernel).to receive(:exit).with(rspec_error_exit_code)
          subject
        end
      end
    end

    describe '#args_with_seed_option_added_when_viable' do
      subject { function_core.args_with_seed_option_added_when_viable(is_seed_used, seed, args) }

      context 'when the order option is not random' do
        let(:args) { ['--order', 'defined'] }
        let(:is_seed_used) { false }
        let(:seed) { nil }

        it 'does not add the seed option to args' do
          expect(subject).to eq ['--order', 'defined']
        end
      end

      ['random', 'rand'].each do |random_option_value|
        context "when the order option is `#{random_option_value}`" do
          let(:args) { ['--order', random_option_value] }

          context 'when the seed is not used' do
            let(:is_seed_used) { false }
            let(:seed) { '123' }

            it 'does not add the seed option to args' do
              expect(subject).to eq ['--order', random_option_value]
            end
          end

          context 'when the seed is used' do
            let(:is_seed_used) { true }
            let(:seed) { '123' }

            it 'adds the seed option to args' do
              expect(subject).to eq ['--order', random_option_value, '--seed', '123']
            end
          end
        end
      end

      context 'when the order option is `rand:123`' do
        let(:args) { ['--order', 'rand:123'] }
        let(:is_seed_used) { true }
        let(:seed) { '123' }

        it 'does not add the seed option to args' do
          expect(subject).to eq ['--order', 'rand:123']
        end
      end

      context 'when the order option is not set in args AND seed is used' do
        let(:args) { ['--format', 'documentation'] }
        let(:is_seed_used) { true }
        let(:seed) { '123' }

        it 'adds the seed option to args' do
          expect(subject).to eq ['--format', 'documentation', '--seed', '123']
        end
      end

      context 'when the order option is not set in args AND seed is not used' do
        let(:args) { ['--format', 'documentation'] }
        let(:is_seed_used) { false }
        let(:seed) { '123' }

        it 'does not add the seed option to args' do
          expect(subject).to eq ['--format', 'documentation']
        end
      end
    end

    describe '#ensure_args_have_a_formatter' do
      subject { function_core.ensure_args_have_a_formatter(args) }

      before do
        expect(KnapsackPro::Adapters::RSpecAdapter).to receive(:has_format_option?).with(args).and_call_original
      end

      context 'when args has no format option' do
        let(:args) { ['--color', '--profile'] }

        it 'adds the progress formatter to args' do
          expect(subject).to eq ['--color', '--profile', '--format', 'progress']
        end
      end

      context 'when has a format option' do
        let(:args) { ['--color', '--format', 'd'] }

        it 'returns args' do
          expect(subject).to eq ['--color', '--format', 'd']
        end
      end
    end

    describe '#args_with_default_options' do
      let(:args) { ['--color', '--format', 'documentation'] }
      let(:test_dir) { 'spec' }

      subject { function_core.args_with_default_options(args, test_dir) }

      it 'adds default options and Knapsack Pro formatters' do
        expect(subject).to eq [
          '--color',
          '--format', 'documentation',
          '--default-path', 'spec',
          '--format', 'KnapsackPro::Formatters::TimeTracker',
        ]
      end
    end

    describe '#log_rspec_command' do
      let(:args) { ['--format', 'documentation'] }
      let(:test_file_paths) { ['a_spec.rb', 'b_spec.rb'] }

      subject { function_core.log_rspec_command(args, test_file_paths, type) }

      context 'when there are no test file paths' do
        let(:type) { :end_of_queue }
        let(:test_file_paths) { [] }

        it 'does not log' do
          expect(logger).to_not receive(:info)

          subject
        end
      end

      context 'when logs the RSpec command for a subset of queue (a batch of tests fetched from the Queue API)' do
        let(:type) { :subset_queue }

        it 'logs the RSpec copy & paste command' do
          expect(logger).to receive(:info).with('To retry the last batch of tests fetched from the Queue API, please run the following command on your machine:')
          expect(logger).to receive(:info).with('bundle exec rspec --format documentation "a_spec.rb" "b_spec.rb"')

          subject
        end
      end

      context 'when logs the RSpec command for all tests fetched from the Queue API' do
        let(:type) { :end_of_queue }

        it 'logs the RSpec copy & paste command' do
          expect(logger).to receive(:info).with('To retry all the tests assigned to this CI node, please run the following command on your machine:')
          expect(logger).to receive(:info).with('bundle exec rspec --format documentation "a_spec.rb" "b_spec.rb"')

          subject
        end
      end

      describe '#log_fail_fast_limit_met' do
        subject { function_core.log_fail_fast_limit_met }

        it 'logs a warning' do
          expect(logger).to receive(:warn).with('Test execution has been canceled because the RSpec --fail-fast option is enabled. It will cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')

          subject
        end
      end

      describe '#log_exit_summary' do
        let(:node_test_file_paths) { ['a_spec.rb', 'b_spec.rb', 'c_spec.rb'] }

        subject { function_core.log_exit_summary(node_test_file_paths) }

        before do
          expect(KnapsackPro::Formatters::TimeTrackerFetcher).to receive(:call).and_return(time_tracker)
        end

        context 'when the KnapsackPro::Formatters::TimeTracker formatter is not found' do
          let(:time_tracker) { nil }

          it 'does nothing' do
            expect(subject).to be_nil
          end
        end

        context 'when the KnapsackPro::Formatters::TimeTracker formatter is found' do
          let(:time_tracker) { instance_double(KnapsackPro::Formatters::TimeTracker) }

          before do
            expect(time_tracker).to receive(:unexecuted_test_files).with(node_test_file_paths).and_return(unexecuted_test_files)
          end

          context 'when there are no unexecuted test files' do
            let(:unexecuted_test_files) { [] }

            it 'does nothing' do
              expect(subject).to be_nil
            end
          end

          context 'when there are unexecuted test files' do
            let(:unexecuted_test_files) { ['b_spec.rb', 'c_spec.rb'] }

            it 'logs a warning' do
              expect(logger).to receive(:warn).with('Unexecuted tests on this CI node (including pending tests): b_spec.rb c_spec.rb')

              subject
            end
          end
        end
      end
    end
  end
end
