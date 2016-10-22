module KnapsackPro
  module Config
    module CI
      class SnapCI < Base
        def node_total
          ENV['SNAP_WORKER_TOTAL']
        end

        def node_index
          index = ENV['SNAP_WORKER_INDEX']
          index.to_i - 1 if index
        end

        def node_build_id
          ENV['SNAP_PIPELINE_COUNTER']
        end

        def commit_hash
          ENV['SNAP_COMMIT']
        end

        # https://docs.snap-ci.com/environment-variables/
        # SNAP_BRANCH - the name of the git branch (not present on pull requests)
        # SNAP_UPSTREAM_BRANCH - the upstream branch for which the pull request was opened
        def branch
          ENV['SNAP_BRANCH'] || ENV['SNAP_UPSTREAM_BRANCH']
        end

        def project_dir
          ENV['SNAP_WORKING_DIR']
        end
      end
    end
  end
end
