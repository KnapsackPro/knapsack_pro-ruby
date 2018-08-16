module KnapsackPro
  module Config
    module CI
      class CirrusCI < Base
        def node_total
          ENV['CI_NODE_TOTAL']
        end

        def node_index
          ENV['CI_NODE_INDEX']
        end

        def node_build_id
          ENV['CIRRUS_BUILD_ID']
        end

        def commit_hash
          ENV['CIRRUS_CHANGE_IN_REPO']
        end

        def branch
          ENV['CIRRUS_BRANCH']
        end

        def project_dir
          ENV['CIRRUS_WORKING_DIR']
        end
      end
    end
  end
end
