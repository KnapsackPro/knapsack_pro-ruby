require 'cucumber'

describe KnapsackPro::TestCaseDetectors::CucumberTestExampleDetector do
  let(:report_dir) { '.knapsack_pro/test_case_detectors/cucumber' }
  let(:report_path) { '.knapsack_pro/test_case_detectors/cucumber/cucumber_dry_run_json_report_node_0.json' }
  let(:cucumber_test_example_detector) { described_class.new }

  around(:each) do |example|
    KnapsackPro.reset_logger!
    $stdout = StringIO.new
    $stderr = StringIO.new
    KnapsackPro.stdout = $stdout
    example.run
    KnapsackPro.stdout = STDOUT
    $stdout = STDOUT
    $stderr = STDERR
    KnapsackPro.reset_logger!
  end

  describe '#dry_run_to_file' do
    subject { cucumber_test_example_detector.dry_run_to_file(cucumber_args) }

    before do
      expect(KnapsackPro::Config::TempFiles).to receive(:ensure_temp_directory_exists!)

      expect(FileUtils).to receive(:mkdir_p).with(report_dir)

      allow(File).to receive(:exist?)
      expect(File).to receive(:exist?).at_least(:once).with(report_path).and_return(true)
      expect(File).to receive(:delete).with(report_path)

      expect(cucumber_test_example_detector).to receive(:fetch_slow_file_paths).and_return(test_file_entities)
    end

    context 'when there are no slow test files' do
      let(:cucumber_args) { '' }
      let(:test_file_entities) { [] }

      before do
        expect(File).to receive(:write).with(report_path, [].to_json)
      end

      it do
        subject
      end
    end

    context 'when slow test files exist' do
      let(:test_file_entities) do
        [
          { 'path' => 'features/a.feature' },
          { 'path' => 'features/b.feature' },
        ]
      end
      let(:cucumber_cli_main) { double }

      before do
        test_dir = 'features'
        expect(KnapsackPro::Config::Env).to receive(:test_dir).and_return(nil)
        expect(KnapsackPro::TestFilePattern).to receive(:test_dir).with(KnapsackPro::Adapters::CucumberAdapter).and_return(test_dir)

        expect(Cucumber::Cli::Main).to receive(:new).with(expected_args + [
          '--dry-run',
          '--format', 'json',
          '--out', report_path,
          '--require', test_dir,
          'features/a.feature', 'features/b.feature',
        ]).and_return(cucumber_cli_main)
      end

      context 'when Cucumber::Cli::Main exits with the status 0' do
        let(:cucumber_args) { '' }
        let(:expected_args) { [] }

        before do
          expect(cucumber_cli_main).to receive(:execute!).and_raise(SystemExit.new(0))
        end

        it do
          subject
        end
      end

      context 'when Cucumber::Cli::Main exits with the status 1' do
        let(:cucumber_args) { '' }
        let(:expected_args) { [] }

        before do
          expect(cucumber_cli_main).to receive(:execute!).and_raise(SystemExit.new(1))
        end

        it do
          expect { subject }.to raise_error(SystemExit) { |error| expect(error.status).to eq 1 }
        end
      end

      context 'when Cucumber CLI args are present including format options' do
        let(:cucumber_args) { '--tags "not @slow" --format pretty --out /tmp/pretty.txt --strict' }
        let(:expected_args) { ['--tags', 'not @slow', '--strict'] }

        before do
          expect(cucumber_cli_main).to receive(:execute!).and_raise(SystemExit.new(0))
        end

        it 'removes formatter options from the args used for the dry run' do
          subject
        end
      end
    end
  end

  describe '#slow_id_paths!' do
    subject { cucumber_test_example_detector.slow_id_paths! }

    context 'when the report exists' do
      before do
        expect(File).to receive(:exist?).with(report_path).and_return(true)
        expect(File).to receive(:read).with(report_path).and_return(json_report)
      end

      context 'when the report has scenarios' do
        let(:json_report) do
          [
            {
              'uri' => 'features/a.feature',
              'elements' => [
                { 'type' => 'background', 'line' => 2 },
                { 'type' => 'scenario', 'line' => 5 },
                { 'type' => 'scenario', 'line' => 9 },
                # scenario outline rows are expanded into separate elements
                { 'type' => 'scenario', 'line' => 17 },
                { 'type' => 'scenario', 'line' => 18 },
              ],
            },
            {
              'uri' => './features/b.feature',
              'elements' => [
                { 'type' => 'scenario', 'line' => 3 },
              ],
            },
          ].to_json
        end

        it 'returns test example paths for scenarios (skipping backgrounds) with cleaned file paths' do
          expect(subject).to eq([
            'features/a.feature:5',
            'features/a.feature:9',
            'features/a.feature:17',
            'features/a.feature:18',
            'features/b.feature:3',
          ])
        end
      end

      context 'when the report is empty' do
        let(:json_report) { [].to_json }

        it { should eq [] }
      end
    end

    context 'when the report does not exist' do
      before do
        expect(File).to receive(:exist?).with(report_path).and_return(false)
      end

      it do
        expect { subject }.to raise_error(RuntimeError, "No report found at #{report_path}")
      end
    end
  end
end
