module KnapsackPro
  module Config
    module CI
      class Travis < Base
        def node_total
          ENV['KNAPSACK_PRO_CI_NODE_TOTAL']
        end

        def node_index
          ENV['KNAPSACK_PRO_CI_NODE_INDEX']
        end

        def commit_hash
          ENV['TRAVIS_COMMIT']
        end

        def branch
          ENV['TRAVIS_BRANCH']
        end

        def project_dir
          ENV['TRAVIS_BUILD_DIR']
        end
      end
    end
  end
end
