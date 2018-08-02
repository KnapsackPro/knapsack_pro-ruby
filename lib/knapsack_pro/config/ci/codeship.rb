module KnapsackPro
  module Config
    module CI
      class Codeship < Base
        def node_total
          # not provided
        end

        def node_index
          # not provided
        end

        def node_build_id
          ENV['CI_BUILD_NUMBER']
        end

        def commit_hash
          ENV['CI_COMMIT_ID']
        end

        def branch
          ENV['CI_BRANCH']
        end

        def project_dir
          # not provided
        end
      end
    end
  end
end
