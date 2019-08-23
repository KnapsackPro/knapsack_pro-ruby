# https://docs.semaphoreci.com/article/12-environment-variables
module KnapsackPro
  module Config
    module CI
      class Semaphore2 < Base
        def node_total
          ENV['SEMAPHORE_JOB_COUNT']
        end

        def node_index
          index = ENV['SEMAPHORE_JOB_INDEX']
          index.to_i - 1 if index
        end

        def node_build_id
          ENV['SEMAPHORE_WORKFLOW_ID']
        end

        def commit_hash
          ENV['SEMAPHORE_GIT_SHA']
        end

        def branch
          ENV['SEMAPHORE_GIT_BRANCH']
        end

        def project_dir
          if ENV['HOME'] && ENV['SEMAPHORE_GIT_DIR']
            "#{ENV['HOME']}/#{ENV['SEMAPHORE_GIT_DIR']}"
          end
        end
      end
    end
  end
end
