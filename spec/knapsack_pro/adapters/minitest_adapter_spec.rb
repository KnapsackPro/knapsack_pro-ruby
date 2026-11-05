describe KnapsackPro::Adapters::MinitestAdapter do
  it do
    expect(described_class::TEST_DIR_PATTERN).to eq 'test/**{,/*/**}/*_test.rb'
  end

  describe '.test_path' do
    subject { described_class.test_path(obj) }

    before do
      parent_of_test_dir = File.expand_path('../../../', File.dirname(__FILE__))
      parent_of_test_dir_regexp = Regexp.new("^#{parent_of_test_dir}")
      described_class.class_variable_set(:@@parent_of_test_dir, parent_of_test_dir_regexp)
    end

    context 'when regular test' do
      class FakeUserTest
        def test_user_age; end

        # method provided by Minitest
        # it returns test method name
        def name
          :test_user_age
        end
      end

      let(:obj) { FakeUserTest.new }

      it { should eq './spec/knapsack_pro/adapters/minitest_adapter_spec.rb' }
    end

    context 'when shared examples test' do
      module FakeSharedExamples
        def test_from_shared_example; end
      end

      class FakeSharedExamplesUserTest
        include FakeSharedExamples

        def location
          "test that use FakeSharedExamples#test_from_shared_example"
        end
      end

      let(:obj) { FakeSharedExamplesUserTest.new }

      it { should eq './spec/knapsack_pro/adapters/minitest_adapter_spec.rb' }
    end
  end

  %w[BindTimeTrackerMinitestPlugin BindNormalModeMinitestPlugin].each do |plugin|
    describe plugin do
      def run_minitest(plugin, body)
        require 'open3'
        script = <<~RUBY
          require 'knapsack_pro'
          require 'minitest'
          tracker = Object.new
          class << tracker
            def stage(path, elapsed, failed: false)
              raise 'negative duration' if elapsed < 0
              puts 'stop'
              puts "failed: \#{path}" if failed
            end
          end
          KnapsackPro.define_singleton_method(:tracker) { tracker }
          KnapsackPro::Adapters::MinitestAdapter.define_singleton_method(:test_path) { |_| 'test/example_test.rb' }
          KnapsackPro::Hooks::Queue.define_singleton_method(:call_before_queue) { puts 'queue' }
          ENV.delete('KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED')
          adapter = KnapsackPro::Adapters::MinitestAdapter.new
          adapter.#{plugin == 'BindNormalModeMinitestPlugin' ? 'bind_normal_mode' : 'bind_time_tracker'}
          class ExampleTest < Minitest::Test
            def test_example; assert true; end
            def before_setup; puts 'setup'; super; end
            def after_teardown; super; puts 'teardown'; end
          end
          #{body}
        RUBY
        output, status = Open3.capture2e(RbConfig.ruby, '-Ilib', '-e', script)
        expect(status.success?).to be(true), output
        output.lines.map(&:chomp)
      end

      it 'times the complete lifecycle and preserves the result' do
        output = run_minitest(plugin, "puts ExampleTest.new('test_example').run.passed?")
        expect(output).to eq((plugin == 'BindNormalModeMinitestPlugin' ? ['queue'] : []) + %w[setup teardown stop true])
      end

      it 'records failures raised after super in after_teardown' do
        output = run_minitest(plugin, <<~RUBY)
          class ExampleTest
            def after_teardown
              super
              flunk 'cleanup failed'
            end
          end
          puts ExampleTest.new('test_example').run.failures.size
        RUBY
        expect(output.last(3)).to eq(['stop', 'failed: test/example_test.rb', '1'])
      end

      it 'does not record skips as failures' do
        output = run_minitest(plugin, <<~RUBY)
          class ExampleTest
            def test_example; skip 'not applicable'; end
          end
          puts ExampleTest.new('test_example').run.skipped?
        RUBY
        expect(output.last).to eq('true')
        expect(output).not_to include('failed: test/example_test.rb')
      end

      [false, true].each do |same_file|
        it "tracks overlapping tests in #{same_file ? 'the same file' : 'different files'}" do
          output = run_minitest(plugin, <<~RUBY)
            tracker = KnapsackPro::Tracker.send(:new)
            KnapsackPro.define_singleton_method(:tracker) { tracker }
            KnapsackPro::Adapters::MinitestAdapter.define_singleton_method(:test_path) do |test|
              #{same_file ? "'test/shared_test.rb'" : '"test/" + test.name + ".rb"'}
            end
            Minitest.define_singleton_method(:clock_time) { 0.0 }
            Process.define_singleton_method(:clock_gettime) { |_| Thread.current[:times].shift }
            started = Queue.new
            finish_a = Queue.new
            finish_b = Queue.new
            ExampleTest.define_method(:test_a) { started << :a; finish_a.pop; assert true }
            ExampleTest.define_method(:test_b) { started << :b; finish_b.pop; flunk 'failed' }
            a = Thread.new do
              Thread.current[:times] = [0.0, 3.0]
              ExampleTest.new('test_a').run
            end
            raise unless started.pop == :a
            b = Thread.new do
              Thread.current[:times] = [1.0, 5.0]
              ExampleTest.new('test_b').run
            end
            raise unless started.pop == :b
            finish_a << true
            a.value
            finish_b << true
            b.value
            tracker.flush_staged_tests
            puts JSON.generate(times: tracker.test_files_with_time, total: tracker.global_time,
                               failures: tracker.current_batch_failed_paths)
          RUBY
          report = JSON.parse(output.last)
          expected_times = same_file ? { 'test/shared_test.rb' => 7.0 } : {
            'test/test_a.rb' => 3.0, 'test/test_b.rb' => 4.0
          }
          expect(report.fetch('times').transform_values { |value| value.fetch('time_execution') }).to eq(expected_times)
          expect(report.fetch('total')).to eq(7.0)
          expect(report.fetch('failures')).to eq([same_file ? 'test/shared_test.rb' : 'test/test_b.rb'])
        end
      end

      if plugin == 'BindNormalModeMinitestPlugin'
        it 'calls the queue hook only once' do
          output = run_minitest(plugin, "2.times { ExampleTest.new('test_example').run }")
          expect(output.count('queue')).to eq 1
          expect(output.first(2)).to eq(%w[queue setup])
        end
      end
    end
  end

  describe 'bind methods' do
    describe '#bind_time_tracker' do
      let(:logger) { instance_double(Logger) }
      let(:global_time) { 'Global time: 01m 05s' }

      it do
        expect(::Minitest::Test).to receive(:send).with(:prepend, KnapsackPro::Adapters::MinitestAdapter::BindTimeTrackerMinitestPlugin)

        expect(::Minitest).to receive(:after_run).and_yield
        expect(KnapsackPro.tracker).to receive(:flush_staged_tests).ordered

        expect(KnapsackPro::Presenter).to receive(:global_time).and_return(global_time)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:debug).with(global_time)

        subject.bind_time_tracker
      end
    end

    describe '#bind_save_report' do
      it do
        test_files = [{ path: 'test/user_test.rb', time_execution: 1.0 }]
        failed_paths = ['test/user_test.rb']
        tracker = instance_double(
          KnapsackPro::Tracker,
          to_a: test_files,
          current_batch_failed_paths: failed_paths
        )

        allow(KnapsackPro).to receive(:tracker).and_return(tracker)
        expect(::Minitest).to receive(:after_run).and_yield

        expect(tracker).to receive(:flush_staged_tests).ordered
        expect(KnapsackPro::Report).to receive(:save).ordered
          .with(test_files, failed_paths)

        subject.bind_save_report
      end
    end

    describe '#bind_normal_mode' do
      let(:logger) { instance_double(Logger) }
      let(:global_time) { 'Global time: 01m 05s' }

      it do
        expect(::Minitest::Test).to receive(:send).with(:prepend, KnapsackPro::Adapters::MinitestAdapter::BindNormalModeMinitestPlugin)

        expect(::Minitest).to receive(:after_run).and_yield
        expect(KnapsackPro.tracker).to receive(:flush_staged_tests).ordered

        expect(KnapsackPro::Presenter).to receive(:global_time).and_return(global_time)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:debug).with(global_time)

        subject.bind_normal_mode
      end
    end
  end

  describe '#set_test_helper_path' do
    let(:adapter) { described_class.new }
    let(:test_helper_path) { '/code/project/test/test_helper.rb' }

    subject { adapter.set_test_helper_path(test_helper_path) }

    after do
      expect(described_class.class_variable_get(:@@parent_of_test_dir)).to eq '/code/project'
    end

    it { should eql '/code/project' }
  end
end
