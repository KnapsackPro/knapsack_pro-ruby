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
      TMP_DIR = 'tmp/knapsack_pro'

      class << self
        def ci_node_total
          (ENV['KNAPSACK_PRO_CI_NODE_TOTAL'] ||
            ci_env_for(:node_total) ||
            1).to_i
        end

        def ci_node_index
          (ENV['KNAPSACK_PRO_CI_NODE_INDEX'] ||
            ci_env_for(:node_index) ||
            0).to_i
        end

        def ci_node_build_id
          ENV['KNAPSACK_PRO_CI_NODE_BUILD_ID'] ||
            ci_env_for(:node_build_id) ||
            'missing-build-id'
        end

        def ci_node_retry_count
          (
            ENV['KNAPSACK_PRO_CI_NODE_RETRY_COUNT'] ||
            ci_env_for(:node_retry_count) ||
            0
          ).to_i
        end

        def max_request_retries
          number = ENV['KNAPSACK_PRO_MAX_REQUEST_RETRIES']
          if number
            number.to_i
          end
        end

        def commit_hash
          ENV['KNAPSACK_PRO_COMMIT_HASH'] ||
            ci_env_for(:commit_hash)
        end

        def branch
          ENV['KNAPSACK_PRO_BRANCH'] ||
            ci_env_for(:branch)
        end

        def project_dir
          ENV['KNAPSACK_PRO_PROJECT_DIR'] ||
            ci_env_for(:project_dir)
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

        def recording_enabled
          ENV['KNAPSACK_PRO_RECORDING_ENABLED']
        end

        def recording_enabled?
          recording_enabled == 'true'
        end

        def regular_mode?
          recording_enabled?
        end

        def queue_recording_enabled
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED']
        end

        def queue_recording_enabled?
          queue_recording_enabled == 'true'
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

        def modify_default_rspec_formatters
          ENV.fetch('KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS', true)
        end

        def modify_default_rspec_formatters?
          modify_default_rspec_formatters.to_s == 'true'
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
          ENV.fetch('KNAPSACK_PRO_FIXED_QUEUE_SPLIT', false)
        end

        def fixed_queue_split?
          fixed_queue_split.to_s == 'true'
        end

        def cucumber_queue_prefix
          ENV.fetch('KNAPSACK_PRO_CUCUMBER_QUEUE_PREFIX', 'bundle exec')
        end

        def rspec_split_by_test_examples
          ENV.fetch('KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES', false)
        end

        def rspec_split_by_test_examples?
          rspec_split_by_test_examples.to_s == 'true'
        end

        def rspec_test_example_detector_prefix
          ENV.fetch('KNAPSACK_PRO_RSPEC_TEST_EXAMPLE_DETECTOR_PREFIX', 'bundle exec')
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

        def ci_env_for(env_name)
          value = nil
          ci_list = KnapsackPro::Config::CI.constants - [:Base, :GitlabCI]
          # load GitLab CI first to avoid edge case with order of loading envs for CI_NODE_INDEX
          ci_list = [:GitlabCI] + ci_list
          ci_list.each do |ci_name|
            ci_class = Object.const_get("KnapsackPro::Config::CI::#{ci_name}")
            ci = ci_class.new
            value = ci.send(env_name)
            break unless value.nil?
          end
          value
        end

        def log_level
          LOG_LEVELS[ENV['KNAPSACK_PRO_LOG_LEVEL'].to_s.downcase] || ::Logger::DEBUG
        end

        def log_dir
          ENV['KNAPSACK_PRO_LOG_DIR']
        end

        private

        def required_env(env_name)
          ENV[env_name] || raise("Missing environment variable #{env_name}")
        end
      end
    end
  end
end
