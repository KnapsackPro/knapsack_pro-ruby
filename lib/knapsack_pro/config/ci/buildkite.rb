module KnapsackPro
  module Config
    module CI
      class Buildkite < Base
        def node_total
          ENV['BUILDKITE_PARALLEL_JOB_COUNT']
        end

        def node_index
          ENV['BUILDKITE_PARALLEL_JOB']
        end

        def commit_hash
          ENV['BUILDKITE_COMMIT']
        end

        def branch
          ENV['BUILDKITE_BRANCH']
        end
      end
    end
  end
end
