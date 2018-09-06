# http://docs.solanolabs.com/Setup/tddium-set-environment-variables/
module KnapsackPro
  module Config
    module CI
      class SolanoCI < Base
        def node_total
          # not provided
        end

        def node_index
          # not provided
        end

        def node_build_id
          ENV['TDDIUM_SESSION_ID']
        end

        def commit_hash
          ENV['TDDIUM_CURRENT_COMMIT']
        end

        def branch
          ENV['TDDIUM_CURRENT_BRANCH']
        end

        def project_dir
          ENV['TDDIUM_REPO_ROOT']
        end
      end
    end
  end
end
