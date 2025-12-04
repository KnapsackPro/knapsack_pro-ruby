describe KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector do
  let(:report_dir) { '.knapsack_pro/test_case_detectors/rspec' }
  let(:report_path) { '.knapsack_pro/test_case_detectors/rspec/rspec_dry_run_json_report_node_0.json' }
  let(:rspec_test_example_detector) { described_class.new }

  describe '#calculate' do
    subject { rspec_test_example_detector.calculate(rspec_args) }

    shared_examples 'calculate runs RSpec::Core::Runner' do
      before do
        expect(KnapsackPro::Config::TempFiles).to receive(:ensure_temp_directory_exists!)

        expect(FileUtils).to receive(:mkdir_p).with(report_dir)

        allow(File).to receive(:exist?)
        expect(File).to receive(:exist?).at_least(:once).with(report_path).and_return(true)
        expect(File).to receive(:delete).with(report_path)

        expect(rspec_test_example_detector).to receive(:slow_test_files).at_least(1).time.and_return(test_file_entities)
      end

      context 'when there are no slow test files' do
        let(:test_file_entities) { [] }

        before do
          expect(File).to receive(:write).with(report_path, { examples: [] }.to_json)
        end

        it do
          subject
        end
      end

      context 'when slow test files exist' do
        let(:test_file_entities) do
          [
            { 'path' => 'spec/a_spec.rb' },
            { 'path' => 'spec/b_spec.rb' },
          ]
        end
        let(:rspec_core_runner) { double }

        before do
          test_dir = 'spec'
          expect(KnapsackPro::Config::Env).to receive(:test_dir).and_return(nil)
          expect(KnapsackPro::TestFilePattern).to receive(:test_dir).with(KnapsackPro::Adapters::RSpecAdapter).and_return(test_dir)

          options = double
          expect(RSpec::Core::ConfigurationOptions).to receive(:new).with(expected_args + [
            '--format', expected_format,
            '--dry-run',
            '--out', report_path,
            '--default-path', test_dir,
            'spec/a_spec.rb', 'spec/b_spec.rb',
          ]).and_return(options)

          expect(RSpec::Core::Runner).to receive(:new).with(options).and_return(rspec_core_runner)
        end

        context 'when exit code from RSpec::Core::Runner is 0' do
          before do
            expect(rspec_core_runner).to receive(:run).with($stderr, $stdout).and_return(0)
          end

          it do
            subject
          end
        end

        context 'when exit code from RSpec::Core::Runner is 1' do
          before do
            expect(rspec_core_runner).to receive(:run).with($stderr, $stdout).and_return(1)
            expect(File).to receive(:read).with(report_path).and_return(<<~JSON.strip)
              {"version":"3.11.0","messages":["An error occurred while loading ./spec/a_spec.rb"],"examples":[],"summary":{"duration":3.6e-05,"example_count":0,"failure_count":0,"pending_count":0,"errors_outside_of_examples_count":1},"summary_line":"0 examples, 0 failures, 1 error occurred outside of examples"}
            JSON
          end

          it do
            expect { subject }.to raise_error(SystemExit) { |error| expect(error.status).to eq 1 }
          end
        end
      end
    end

    context 'when RSpec >= 3.6.0' do
      let(:rspec_args) { '' }
      let(:expected_args) { [] }
      let(:expected_format) { 'json' }

      it_behaves_like 'calculate runs RSpec::Core::Runner'
    end

    context 'when RSpec < 3.6.0' do
      let(:rspec_args) { '' }
      let(:expected_args) { [] }
      let(:expected_format) { 'KnapsackPro::Formatters::RSpecJsonFormatter' }

      before do
        stub_const('RSpec::Core::Version::STRING', '3.5.0')
      end

      it_behaves_like 'calculate runs RSpec::Core::Runner'
    end

    context 'when RSpec CLI args are present including format option' do
      let(:rspec_args) { '-t mytag --format documentation --out /tmp/documentation.txt --tag ~@skip --example-matches regexp --example string' }
      let(:expected_args) { ['-t', 'mytag', '--tag', '~@skip', '--example-matches', 'regexp', '--example', 'string'] }
      let(:expected_format) { 'json' }

      describe 'removes formatters from RSpec CLI args' do
        it_behaves_like 'calculate runs RSpec::Core::Runner'
      end
    end

    context 'with --force-color' do
      let(:rspec_args) { '--force-color' }
      let(:expected_args) { ['--force-color'] }
      let(:expected_format) { 'json' }

      it_behaves_like 'calculate runs RSpec::Core::Runner'
    end

    context 'with --no-color and --force-color' do
      let(:rspec_args) { '--no-color --force-color' }

      after { KnapsackPro.reset_logger! }

      it do
        subject_class = Class.new(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector) do
          define_method(:slow_test_files) do
            [{ 'path' => 'spec/a_spec.rb' }]
          end
        end

        expect do
          KnapsackPro.logger = ::Logger.new($stdout)
          subject_class.new.calculate(rspec_args)
        end
          .to output(/Please only use one of `--force-color` and `--no-color`/).to_stderr
          .and output(%r{ERROR -- : \[knapsack_pro\] Failed to calculate Split by Test Examples: bundle exec rspec --no-color --force-color --format json --dry-run --out .knapsack_pro/test_case_detectors/rspec/rspec_dry_run_json_report_node_0.json --default-path spec spec/a_spec.rb}).to_stdout
          .and raise_error(SystemExit) { |error| expect(error.status).to eq 1 }
      end
    end
  end

  describe '#slow_id_paths!' do
    subject { described_class.new.slow_id_paths! }

    context 'when JSON report exists' do
      it do
        expect(File).to receive(:exist?).with(report_path).and_return(true)

        json_file = {
          'examples' => [
            { id: './spec/a_spec.rb[1:1]' },
            { id: './spec/a_spec.rb[1:2]' },
          ]
        }.to_json
        expect(File).to receive(:read).with(report_path).and_return(json_file)

        expect(subject).to eq([
          'spec/a_spec.rb[1:1]',
          'spec/a_spec.rb[1:2]'
        ])
      end
    end

    context 'when JSON report does not exist' do
      it do
        expect(File).to receive(:exist?).with(report_path).and_return(false)

        expect { subject }.to raise_error(RuntimeError, "No report found at .knapsack_pro/test_case_detectors/rspec/rspec_dry_run_json_report_node_0.json")
      end
    end
  end

  describe '#slow_test_files' do
    subject { described_class.new.send(:slow_test_files) }

    before do
      expect(KnapsackPro::Config::Env).to receive(:slow_test_file_pattern).and_return(slow_test_file_pattern)
    end

    context 'when slow test file pattern is present' do
      let(:slow_test_file_pattern) { double }

      it do
        expected_slow_test_files = double
        expect(KnapsackPro::TestFileFinder).to receive(:slow_test_files_by_pattern).with(KnapsackPro::Adapters::RSpecAdapter).and_return(expected_slow_test_files)

        expect(subject).to eq expected_slow_test_files
      end
    end

    context 'when slow test file pattern is not present' do
      let(:slow_test_file_pattern) { nil }

      it do
        expected_slow_test_files = double
        expect(KnapsackPro::SlowTestFileFinder).to receive(:call).and_return(expected_slow_test_files)

        expect(subject).to eq expected_slow_test_files
      end
    end
  end
end
