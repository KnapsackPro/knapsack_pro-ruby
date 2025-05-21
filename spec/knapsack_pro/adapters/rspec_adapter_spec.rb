require_relative '../../../lib/knapsack_pro/formatters/time_tracker'

describe KnapsackPro::Adapters::RSpecAdapter do
  it 'backwards compatibility with knapsack gem old rspec adapter name' do
    expect(KnapsackPro::Adapters::RspecAdapter.new).to be_kind_of(described_class)
  end

  it do
    expect(described_class::TEST_DIR_PATTERN).to eq 'spec/**{,/*/**}/*_spec.rb'
  end

  context do
    before { expect(::RSpec).to receive(:configure).at_least(:once) }
    it_behaves_like 'adapter'
  end

  describe '.split_by_test_cases_enabled?' do
    subject { described_class.split_by_test_cases_enabled? }

    before do
      expect(KnapsackPro::Config::Env).to receive(:rspec_split_by_test_examples?).and_return(rspec_split_by_test_examples_enabled)
    end

    context 'when the RSpec split by test examples is enabled' do
      let(:rspec_split_by_test_examples_enabled) { true }

      it { expect(subject).to be true }

      context 'when the RSpec version is < 3.3.0' do
        before do
          stub_const('RSpec::Core::Version::STRING', '3.2.0')
        end

        it do
          expect { subject }.to raise_error RuntimeError, 'RSpec >= 3.3.0 is required to split test files by test examples. Learn more: https://knapsackpro.com/perma/ruby/split-by-test-examples'
        end
      end
    end

    context 'when the RSpec split by test examples is disabled' do
      let(:rspec_split_by_test_examples_enabled) { false }

      it { expect(subject).to be false }
    end
  end

  describe '.test_file_cases_for' do
    let(:slow_test_files) do
      [
        '1_spec.rb',
        '2_spec.rb',
        '3_spec.rb',
        '4_spec.rb',
        '5_spec.rb',
      ]
    end

    subject { described_class.test_file_cases_for(slow_test_files) }

    context 'when the rake task to detect RSpec test examples succeeded' do
      it 'returns test example paths for slow test files' do
        logger = instance_double(Logger)
        allow(KnapsackPro).to receive(:logger).and_return(logger)
        allow(logger).to receive(:info)

        cmd = 'bundle exec rake knapsack_pro:rspec_test_example_detector'
        env = { 'RACK_ENV' => 'test', 'RAILS_ENV' => 'test' }
        expect(Kernel).to receive(:system).with(env, cmd).and_return(true)

        rspec_test_example_detector = instance_double(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector)
        expect(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector).to receive(:new).and_return(rspec_test_example_detector)

        test_file_example_paths = double
        expect(rspec_test_example_detector).to receive(:test_file_example_paths).and_return(test_file_example_paths)

        expect(subject).to eq test_file_example_paths

        expect(logger).to have_received(:info).with("Generating RSpec test examples JSON report for slow test files to prepare it to be split by test examples (by individual test cases). Thanks to that, a single slow test file can be split across parallel CI nodes. Analyzing 5 slow test files.")
      end
    end

    context 'when KNAPSACK_PRO_RSPEC_TEST_EXAMPLE_DETECTOR_PREFIX is set with a custom environment variable' do
      it 'calls Kernel.system using a single command including ENVs that is passed to a shell (does not work in a distroless environment)' do
        stub_const('ENV', { 'KNAPSACK_PRO_RSPEC_TEST_EXAMPLE_DETECTOR_PREFIX' => 'CUSTOM_ENV_VAR=123 bundle exec' })

        cmd = 'CUSTOM_ENV_VAR=123 bundle exec rake knapsack_pro:rspec_test_example_detector'
        env = { 'RACK_ENV' => 'test', 'RAILS_ENV' => 'test' }
        expect(Kernel).to receive(:system).with(env, cmd).and_return(true)

        rspec_test_example_detector = instance_double(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector)
        expect(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector).to receive(:new).and_return(rspec_test_example_detector)

        test_file_example_paths = double
        expect(rspec_test_example_detector).to receive(:test_file_example_paths).and_return(test_file_example_paths)

        expect(subject).to eq test_file_example_paths
      end
    end

    context 'when the rake task to detect RSpec test examples failed' do
      it do
        cmd = 'bundle exec rake knapsack_pro:rspec_test_example_detector'
        env = { 'RACK_ENV' => 'test', 'RAILS_ENV' => 'test' }
        expect(Kernel).to receive(:system).with(env, cmd).and_return(false)

        expect { subject }.to raise_error(RuntimeError, 'Could not generate JSON report for RSpec. Rake task failed when running RACK_ENV=test RAILS_ENV=test bundle exec rake knapsack_pro:rspec_test_example_detector')
      end
    end
  end

  describe '.has_format_option?' do
    subject { described_class.has_format_option?(cli_args) }

    context 'when format option is provided as -f' do
      let(:cli_args) { ['-f', 'documentation'] }

      it { expect(subject).to be true }
    end

    context 'when format option is provided as --format' do
      let(:cli_args) { ['--format', 'documentation'] }

      it { expect(subject).to be true }
    end

    context 'when format option is provided without delimiter' do
      let(:cli_args) { ['-fd'] }

      it { expect(subject).to be true }
    end

    context 'when format option is not provided' do
      let(:cli_args) { ['--fake', 'value'] }

      it { expect(subject).to be false }
    end
  end

  describe '.has_require_rails_helper_option?' do
    subject { described_class.has_require_rails_helper_option?(cli_args) }

    context 'when require option is provided as -r' do
      let(:cli_args) { ['-r', 'rails_helper'] }

      it { expect(subject).to be true }
    end

    context 'when require option is provided as --require' do
      let(:cli_args) { ['--require', 'rails_helper'] }

      it { expect(subject).to be true }
    end

    context 'when require option is provided without delimiter' do
      let(:cli_args) { ['-rrails_helper'] }

      it { expect(subject).to be true }
    end

    context 'when require option is not provided' do
      let(:cli_args) { ['--fake', 'value'] }

      it { expect(subject).to be false }
    end
  end

  describe '.id_path?' do
    subject { described_class.id_path?(path) }

    context 'when the path is an RSpec path with id' do
      let(:path) { 'spec/features/a_spec.rb[1:1:7:1]' }

      it { is_expected.to be true }
    end

    context 'when the path is an RSpec path with multiple ids' do
      let(:path) { 'spec/features/a_spec.rb[1:1:7:1, 1:2]' }

      it { is_expected.to be true }
    end

    context 'when the path is an RSpec path with no id' do
      let(:path) { 'spec/features/a_spec.rb' }

      it { is_expected.to be false }
    end

    context 'when the path is a Turnip path with id' do
      let(:path) { 'spec/acceptance/a.feature[1:1:7:1]' }

      it { is_expected.to be true }
    end

    context 'when the path is a Turnip path with multiple ids' do
      let(:path) { 'spec/acceptance/a.feature[1:1:7:1,1:2]' }

      it { is_expected.to be true }
    end

    context 'when the path is a Turnip path with no id' do
      let(:path) { 'spec/acceptance/a.feature' }

      it { is_expected.to be false }
    end
  end

  describe '.rails_helper_exists?' do
    subject { described_class.rails_helper_exists?(test_dir) }

    let(:test_dir) { 'spec_fake' }

    context 'when rails_helper exists' do
      before do
        File.open("#{test_dir}/rails_helper.rb", 'w')
      end

      after do
        FileUtils.rm("#{test_dir}/rails_helper.rb")
      end

      it { expect(subject).to be true }
    end

    context 'when rails_helper does not exist' do
      before do
        FileUtils.rm_f("#{test_dir}/rails_helper.rb")
      end

      it { expect(subject).to be false }
    end
  end

  describe '.order_option' do
    subject { described_class.order_option(cli_args) }

    context "when order is 'defined'" do
      let(:cli_args) { ['--order', 'defined'] }

      it { expect(subject).to eq 'defined' }
    end

    context "when order is 'recently-modified'" do
      let(:cli_args) { ['--order', 'recently-modified'] }

      it { expect(subject).to eq 'recently-modified' }
    end

    context "when order is 'rand'" do
      let(:cli_args) { ['--order', 'rand'] }

      it { expect(subject).to eq 'rand' }

      context 'with the seed' do
        let(:cli_args) { ['--order', 'rand:123456'] }

        it { expect(subject).to eq 'rand:123456' }
      end
    end

    context "when order is 'random'" do
      let(:cli_args) { ['--order', 'random'] }

      it { expect(subject).to eq 'random' }

      context 'with the seed' do
        let(:cli_args) { ['--order', 'random:123456'] }

        it { expect(subject).to eq 'random:123456' }
      end
    end

    context 'when some custom order is specified' do
      let(:cli_args) { ['--order', 'some-custom-order'] }

      it { expect(subject).to eq 'some-custom-order' }
    end

    context "when the seed is given with the --seed command" do
      let(:cli_args) { ['--seed', '123456'] }

      it { expect(subject).to eq 'rand:123456' }
    end
  end

  describe '.remove_formatters' do
    subject { described_class.remove_formatters(cli_args) }

    context "when CLI args include formatters" do
      let(:cli_args) { ['-t', 'awesome_tag', '-f', 'documentation', '-o', '/tmp/documentation.txt', '--tag', 'mytag', '--format', 'json', '--out', '/tmp/file.json', '--no-color'] }

      it 'removes formatters and the related output file options' do
        expect(subject).to eq ['-t', 'awesome_tag', '--tag', 'mytag', '--no-color']
      end
    end
  end

  describe '.file_path_for' do
    let(:current_example) { ::RSpec.describe.example }

    subject { described_class.file_path_for(current_example) }

    context "when id ends in _spec.rb" do
      it "returns the first part of the id" do
        allow(current_example).to receive(:id).and_return("./foo_spec.rb[1:1]")

        expect(subject).to eq('./foo_spec.rb')
      end
    end

    context "when id does not end in _spec.rb" do
      it "returns the file_path" do
        allow(current_example).to receive(:id).and_return("./foo.rb")
        allow(current_example).to receive(:metadata).and_return(file_path: "./foo_spec.rb")

        expect(subject).to eq('./foo_spec.rb')
      end
    end

    context "when id and file_path do not end in _spec.rb" do
      it "returns the example_group's file_path" do
        allow(current_example).to receive(:id).and_return("./foo.rb")
        allow(current_example).to receive(:metadata).and_return(
          file_path: "./foo.rb", example_group: { file_path: "./foo_spec.rb" }
        )

        expect(subject).to eq('./foo_spec.rb')
      end
    end

    context "when id, file_path, and example_group's file_path do not end in _spec.rb" do
      it "returns the top_level_group's file_path" do
        allow(current_example).to receive(:id).and_return("./foo.rb")
        allow(current_example).to receive(:metadata).and_return(
          file_path: "./foo.rb",
          example_group: {
            file_path: "./foo.rb",
            parent_example_group: {
              file_path: "./foo_spec.rb",
            }
          }
        )

        expect(subject).to eq('./foo_spec.rb')
      end
    end

    context "when id, file_path, example_group's, and top_level_group's file_path do not end in _spec.rb" do
      it "returns empty string" do
        allow(current_example).to receive(:id).and_return("./foo.rb")
        allow(current_example).to receive(:metadata).and_return(
          file_path: "./foo.rb",
          example_group: {
            file_path: "./foo.rb",
            parent_example_group: {
              file_path: "./foo.rb",
            }
          }
        )

        expect(subject).to eq('')
      end
    end

    context "when id does not end in .feature (nor _spec.rb)" do
      it "returns the file_path" do
        allow(current_example).to receive(:id).and_return("./foo.rb")
        allow(current_example).to receive(:metadata).and_return(file_path: "./foo.feature")

        expect(subject).to eq("./foo.feature")
      end
    end
  end

  describe 'private .scheduled_paths' do
    subject { described_class.send(:scheduled_paths) }

    context 'when the RSpec configuration has files or directories to run' do
      it 'returns list of test files passed to RSpec (if this fails then the internal RSpec API changed and we must start supporting a new RSpec version as well)' do
        expect(subject).not_to be_empty
      end
    end

    context "when the RSpec configuration has no files or directories to run (when the internal RSpec API changed and we don't support the new RSpec version yet)" do
      before do
        expect(described_class).to receive(:rspec_configuration).and_return(double(:object_with_no_instance_variables))
      end

      it 'fallbacks to an empty array to not blow up Knapsack Pro' do
        expect(subject).to eq([])
      end
    end
  end

  describe 'bind methods' do
    let(:config) { double }

    describe '#bind_time_tracker' do
      let(:current_example) { double(metadata: {}) }

      context "when the example's metadata has :focus tag AND RSpec inclusion rule includes :focus" do
        let(:current_example) { double(metadata: { focus: true }) }
        let(:test_path) { 'spec/a_spec.rb' }

        it do
          expect(config).to receive(:around).with(:each).and_yield(current_example)
          expect(::RSpec).to receive(:configure).and_yield(config)

          expect(described_class).to receive(:file_path_for).with(current_example).and_return(test_path)

          expect(described_class).to receive_message_chain(:rspec_configuration, :filter, :rules, :[]).with(:focus).and_return(true)

          expect {
            subject.bind_time_tracker
          }.to raise_error /Knapsack Pro found an example tagged with focus in spec\/a_spec\.rb/i
        end
      end

      context 'with no focus' do
        it 'records time for current test path' do
          expect(config).to receive(:around).with(:each).and_yield(current_example)
          expect(config).to receive(:append_after).with(:suite)
          expect(::RSpec).to receive(:configure).at_least(1).and_yield(config)

          expect(current_example).to receive(:run)

          subject.bind_time_tracker
        end
      end
    end

    describe '#bind_save_report' do
      it do
        expect(config).to receive(:after).with(:suite).and_yield
        expect(::RSpec).to receive(:configure).and_yield(config)

        time_tracker = instance_double(KnapsackPro::Formatters::TimeTracker)
        times = [{ path: "foo_spec.rb", time_execution: 1.0 }]
        expect(time_tracker).to receive(:batch).and_return(times)
        expect(KnapsackPro::Formatters::TimeTrackerFetcher).to receive(:call).and_return(time_tracker)
        expect(KnapsackPro::Report).to receive(:save).with(times)

        subject.bind_save_report
      end
    end
  end
end
