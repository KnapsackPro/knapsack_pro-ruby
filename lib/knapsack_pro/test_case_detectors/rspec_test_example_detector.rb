module KnapsackPro
  module TestCaseDetectors
    class RSpecTestExampleDetector
      def generate_json_report
        require 'rspec/core'

        test_file_paths = KnapsackPro::TestFileFinder.call(test_file_pattern)

        cli_args = [
          '--dry-run',
          '--format', 'json',
          '--default-path', test_dir,
        ] + test_file_paths.map { |t| t.fetch('path') }
        options = RSpec::Core::ConfigurationOptions.new(cli_args)

        #fake_stdout = StringIO.new
        #exit_code = RSpec::Core::Runner.new(options).run($stderr, fake_stdout)
        exit_code = RSpec::Core::Runner.new(options).run($stderr, $stdout)
        if exit_code != 0
          raise 'There was problem to generate test examples for test suite'
        end
      end

      private

      def adapter_class
        KnapsackPro::Adapters::RSpecAdapter
      end

      def test_dir
        KnapsackPro::Config::Env.test_dir || TestFilePattern.test_dir(adapter_class)
      end

      def test_file_pattern
        TestFilePattern.call(adapter_class)
      end
    end
  end
end
