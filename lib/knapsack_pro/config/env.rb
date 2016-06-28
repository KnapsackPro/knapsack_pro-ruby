module KnapsackPro
  module Config
    class Env
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

        def repository_adapter
          ENV['KNAPSACK_PRO_REPOSITORY_ADAPTER']
        end

        def recording_enabled
          ENV['KNAPSACK_PRO_RECORDING_ENABLED']
        end

        def recording_enabled?
          recording_enabled == 'true'
        end

        def endpoint
          env_name = 'KNAPSACK_PRO_ENDPOINT'
          return ENV[env_name] if ENV[env_name]

          case mode
          when :development
            'http://api.knapsackpro.dev:3000'
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

        def test_suite_token
          required_env('KNAPSACK_PRO_TEST_SUITE_TOKEN')
        end

        def test_suite_token_rspec
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC']
        end

        def test_suite_token_minitest
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST']
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
          ci_list = KnapsackPro::Config::CI.constants - [:Base]
          ci_list.each do |ci_name|
            ci_class = Object.const_get("KnapsackPro::Config::CI::#{ci_name}")
            ci = ci_class.new
            value = ci.send(env_name)
            break unless value.nil?
          end
          value
        end

        private

        def required_env(env_name)
          ENV[env_name] || raise("Missing environment variable #{env_name}")
        end
      end
    end
  end
end
