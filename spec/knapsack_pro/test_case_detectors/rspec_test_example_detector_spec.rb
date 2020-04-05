describe KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector do
  let(:report_dir) { 'tmp/knapsack_pro/test_case_detectors/rspec' }
  let(:report_path) { 'tmp/knapsack_pro/test_case_detectors/rspec/rspec_dry_run_json_report.json' }

  describe '#generate_json_report' do
    subject { described_class.new.generate_json_report }

    before do
      expect(FileUtils).to receive(:mkdir_p).with(report_dir)

      expect(File).to receive(:exists?).with(report_path).and_return(true)
      expect(File).to receive(:delete).with(report_path)

      test_file_pattern = double
      adapter_class = KnapsackPro::Adapters::RSpecAdapter
      expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

      test_file_paths = [
        { 'path' => 'spec/a_spec.rb' },
        { 'path' => 'spec/b_spec.rb' },
      ]
      expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_file_paths)

      test_dir = 'spec'
      expect(KnapsackPro::Config::Env).to receive(:test_dir).and_return(nil)
      expect(KnapsackPro::TestFilePattern).to receive(:test_dir).with(adapter_class).and_return(test_dir)

      options = double
      expect(RSpec::Core::ConfigurationOptions).to receive(:new).with([
        '--dry-run',
        '--format', 'json',
        '--out', report_path,
        '--default-path', test_dir,
        'spec/a_spec.rb', 'spec/b_spec.rb',
      ]).and_return(options)

      rspec_core_runner = double
      expect(RSpec::Core::Runner).to receive(:new).with(options).and_return(rspec_core_runner)
      expect(rspec_core_runner).to receive(:run).with($stderr, $stdout).and_return(exit_code)
    end

    context 'when exit code from RSpec::Core::Runner is 0' do
      let(:exit_code) { 0 }

      it do
        expect(subject).to be_nil
      end
    end

    context 'when exit code from RSpec::Core::Runner is 1' do
      let(:exit_code) { 1 }

      it do
        expect { subject }.to raise_error(RuntimeError, 'There was problem to generate test examples for test suite')
      end
    end
  end

  describe '#test_file_example_paths' do
    subject { described_class.new.test_file_example_paths }

    context 'when json report exists' do
      it do
        expect(File).to receive(:exists?).with(report_path).and_return(true)

        json_file = {
          'examples' => [
            { id: './spec/a_spec.rb[1:1]' },
            { id: './spec/a_spec.rb[1:2]' },
          ]
        }.to_json
        expect(File).to receive(:read).with(report_path).and_return(json_file)

        expect(subject).to eq([
          { 'path' => 'spec/a_spec.rb[1:1]' },
          { 'path' => 'spec/a_spec.rb[1:2]' },
        ])
      end
    end

    context 'when json report does not exist' do
      it do
        expect(File).to receive(:exists?).with(report_path).and_return(false)

        expect { subject }.to raise_error(RuntimeError, 'No report found at tmp/knapsack_pro/test_case_detectors/rspec/rspec_dry_run_json_report.json')
      end
    end
  end
end
