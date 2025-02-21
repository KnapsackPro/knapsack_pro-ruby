# frozen_string_literal: true

module KnapsackPro
  module Config
    class Env
      LOG_LEVELS = {
        'fatal'  => ::Logger::FATAL,
        'error'  => ::Logger::ERROR,
        'warn'  => ::Logger::WARN,
        'info'  => ::Logger::INFO,
        'debug' => ::Logger::DEBUG,
      }

      class << self
        def ci_node_total
          (env_for('KNAPSACK_PRO_CI_NODE_TOTAL', :node_total) || 1).to_i
        end

        def ci_node_index
          (env_for('KNAPSACK_PRO_CI_NODE_INDEX', :node_index) || 0).to_i
        end

        def ci_node_build_id
          env_name = 'KNAPSACK_PRO_CI_NODE_BUILD_ID'
          env_for(env_name, :node_build_id) ||
            raise("Missing environment variable #{env_name}. Read more at #{KnapsackPro::Urls::KNAPSACK_PRO_CI_NODE_BUILD_ID}")
        end

        def ci_node_retry_count
          (env_for('KNAPSACK_PRO_CI_NODE_RETRY_COUNT', :node_retry_count) || 0).to_i
        end

        def max_request_retries
          number = ENV['KNAPSACK_PRO_MAX_REQUEST_RETRIES']
          if number
            number.to_i
          end
        end

        def commit_hash
          env_for('KNAPSACK_PRO_COMMIT_HASH', :commit_hash)
        end

        def branch
          env_for('KNAPSACK_PRO_BRANCH', :branch)
        end

        def project_dir
          env_for('KNAPSACK_PRO_PROJECT_DIR', :project_dir)
        end

        def user_seat
          env_for('KNAPSACK_PRO_USER_SEAT', :user_seat)
        end

        def masked_user_seat
          return unless user_seat

          KnapsackPro::MaskString.call(user_seat)
        end

        def test_file_pattern
          ENV['KNAPSACK_PRO_TEST_FILE_PATTERN']
        end

        def slow_test_file_pattern
          ENV['KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN']
        end

        def test_file_exclude_pattern
          ENV['KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN']
        end

        def test_file_list
          ENV['KNAPSACK_PRO_TEST_FILE_LIST']
        end

        def test_file_list_source_file
          ENV['KNAPSACK_PRO_TEST_FILE_LIST_SOURCE_FILE']
        end

        def test_dir
          ENV['KNAPSACK_PRO_TEST_DIR']
        end

        def repository_adapter
          ENV['KNAPSACK_PRO_REPOSITORY_ADAPTER']
        end

        def regular_mode?
          ENV['KNAPSACK_PRO_REGULAR_MODE_ENABLED'] == 'true'
        end

        def queue_mode?
          ENV['KNAPSACK_PRO_QUEUE_MODE_ENABLED'] == 'true'
        end

        def queue_id
          ENV['KNAPSACK_PRO_QUEUE_ID'] || raise('Missing Queue ID')
        end

        def subset_queue_id
          ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] || raise('Missing Subset Queue ID')
        end

        def fallback_mode_enabled
          ENV.fetch('KNAPSACK_PRO_FALLBACK_MODE_ENABLED', true)
        end

        def fallback_mode_enabled?
          fallback_mode_enabled.to_s == 'true'
        end

        def test_files_encrypted
          ENV['KNAPSACK_PRO_TEST_FILES_ENCRYPTED']
        end

        def test_files_encrypted?
          test_files_encrypted == 'true'
        end

        def branch_encrypted
          ENV['KNAPSACK_PRO_BRANCH_ENCRYPTED']
        end

        def branch_encrypted?
          branch_encrypted == 'true'
        end

        def salt
          required_env('KNAPSACK_PRO_SALT')
        end

        def endpoint
          env_name = 'KNAPSACK_PRO_ENDPOINT'
          return ENV[env_name] if ENV[env_name]

          case mode
          when :development
            'http://api.knapsackpro.test:3000'
          when :test
            'https://api-staging.knapsackpro.com'
          when :production
            'https://api.knapsackpro.com'
          else
            required_env(env_name)
          end
        end

        def fixed_test_suite_split
          ENV.fetch('KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT', true)
        end

        def fixed_test_suite_split?
          fixed_test_suite_split.to_s == 'true'
        end

        def fixed_queue_split
          @fixed_queue_split ||= begin
            env_name = 'KNAPSACK_PRO_FIXED_QUEUE_SPLIT'
            computed = env_for(env_name, :fixed_queue_split).to_s

            if !ENV.key?(env_name)
              KnapsackPro.logger.info("#{env_name} is not set. Using default value: #{computed}. Learn more at #{KnapsackPro::Urls::FIXED_QUEUE_SPLIT}")
            end

            computed
          end
        end

        def fixed_queue_split?
          fixed_queue_split.to_s == 'true'
        end

        def cucumber_queue_prefix
          ENV.fetch('KNAPSACK_PRO_CUCUMBER_QUEUE_PREFIX', 'bundle exec')
        end

        # To detect `::Turnip`, the gem must be present in the gemfile
        # with autorequire (default) and have been required.
        # Since `rspec_split_by_test_examples?` is called via the
        # Rails' `Rakefile`, `config/application.rb` should have
        # performed the require.
        def rspec_split_by_test_examples?
          return @rspec_split_by_test_examples if defined?(@rspec_split_by_test_examples)

          env = ENV['KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES']

          if defined?(::Turnip) && env.nil?
            KnapsackPro.logger.warn("The turnip gem was required, so split by test examples is disabled. If you don't use turnip for this test run, you can enable split by test examples with KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES=true. Read more: #{KnapsackPro::Urls::SPLIT_BY_TEST_EXAMPLES}")
            return (@rspec_split_by_test_examples = false)
          end

          split = (env || true).to_s == 'true'

          if split && ci_node_total < 2
            KnapsackPro.logger.debug('Skipping split of test files by test examples because you are running tests on a single CI node (no parallelism)')
            @rspec_split_by_test_examples = false
          else
            @rspec_split_by_test_examples = split
          end
        end

        def rspec_test_example_detector_prefix
          ENV.fetch('KNAPSACK_PRO_RSPEC_TEST_EXAMPLE_DETECTOR_PREFIX', 'bundle exec')
        end

        def slow_test_file_threshold
          ENV.fetch('KNAPSACK_PRO_SLOW_TEST_FILE_THRESHOLD', nil)&.to_f
        end

        def slow_test_file_threshold?
          !!slow_test_file_threshold
        end

        def test_suite_token
          env_name = 'KNAPSACK_PRO_TEST_SUITE_TOKEN'
          ENV[env_name] || raise("Missing environment variable #{env_name}. You should set environment variable like #{env_name}_RSPEC (note there is suffix _RSPEC at the end). knapsack_pro gem will set #{env_name} based on #{env_name}_RSPEC value. If you use other test runner than RSpec then use proper suffix.")
        end

        def test_suite_token_rspec
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC']
        end

        def test_suite_token_minitest
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST']
        end

        def test_suite_token_test_unit
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_TEST_UNIT']
        end

        def test_suite_token_cucumber
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER']
        end

        def test_suite_token_spinach
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH']
        end

        def mode
          mode = ENV['KNAPSACK_PRO_MODE']
          return :production if mode.nil?
          mode = mode.to_sym
          if [:development, :test, :production].include?(mode)
            mode
          else
            raise ArgumentError.new('Wrong mode name')
          end
        end

        def detected_ci
          detected = KnapsackPro::Config::CI.constants.map do |constant|
            Object.const_get("KnapsackPro::Config::CI::#{constant}").new.detected
          end
            .compact
            .first

          detected || KnapsackPro::Config::CI::Base
        end

        def ci_provider
          detected_ci.new.ci_provider
        end

        def log_level
          LOG_LEVELS[ENV['KNAPSACK_PRO_LOG_LEVEL'].to_s.downcase] || ::Logger::INFO
        end

        def log_dir
          ENV['KNAPSACK_PRO_LOG_DIR']
        end

        def test_runner_adapter
          ENV['KNAPSACK_PRO_TEST_RUNNER_ADAPTER']
        end

        def set_test_runner_adapter(adapter_class)
          ENV['KNAPSACK_PRO_TEST_RUNNER_ADAPTER'] = adapter_class.to_s.split('::').last
        end

        def ci?
          ENV.fetch('CI', 'false').downcase == 'true' ||
            detected_ci != KnapsackPro::Config::CI::Base
        end

        def fallback_mode_error_exit_code
          ENV.fetch('KNAPSACK_PRO_FALLBACK_MODE_ERROR_EXIT_CODE', 1).to_i
        end

        private

        def required_env(env_name)
          ENV[env_name] || raise("Missing environment variable #{env_name}")
        end

        def env_for(knapsack_env_name, ci_env_method)
          knapsack_env_value = ENV[knapsack_env_name]
          ci_env_value = ci_env_for(ci_env_method)

          if !knapsack_env_value.nil? && !ci_env_value.nil? && knapsack_env_value != ci_env_value.to_s
            KnapsackPro.logger.info("You have set the environment variable #{knapsack_env_name} to #{knapsack_env_value} which could be automatically determined from the CI environment as #{ci_env_value}.")
          end

          knapsack_env_value != nil ? knapsack_env_value : ci_env_value
        end

        def ci_env_for(env_name)
          detected_ci.new.send(env_name)
        end
      end
    end
  end
end
