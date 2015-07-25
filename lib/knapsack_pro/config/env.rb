module KnapsackPro
  module Config
    class Env
      class << self
        def ci_node_total
          ENV['KNAPSACK_PRO_CI_NODE_TOTAL'] ||
            ci_env_for(:ci_node_total) ||
            1
        end

        def ci_node_index
          ENV['KNAPSACK_PRO_CI_NODE_INDEX'] ||
            ci_env_for(:ci_node_index) ||
            0
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

        private

        CI_LIST = [
          KnapsackPro::Config::CI::Circle,
          KnapsackPro::Config::CI::Semaphore,
          KnapsackPro::Config::CI::Buildkite,
        ]

        def ci_env_for(env_name)
          value = nil
          CI_LIST.each do |ci_class|
            ci = ci_class.new
            value = ci.send(env_name)
            break unless value.nil?
          end
          value
        end
      end
    end
  end
end
