# https://codefresh.io/docs/docs/codefresh-yaml/variables/#system-provided-variables
module KnapsackPro
  module Config
    module CI
      class Codefresh < Base
        def node_total
          # not provided
        end

        def node_index
          # not provided
        end

        def node_build_id
          ENV['CF_BUILD_ID']
        end

        def commit_hash
          ENV['CF_REVISION']
        end

        def branch
          ENV['CF_BRANCH']
        end

        def project_dir
          # not provided
        end
      end
    end
  end
end
