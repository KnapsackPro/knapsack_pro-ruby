# https://docs.gitlab.com/ce/ci/variables/
module KnapsackPro
  module Config
    module CI
      class GitlabCI < Base
        def node_total
          # not provided by Gitlab CI
        end

        def node_index
          # not provided by Gitlab CI
        end

        def node_build_id
          ENV['CI_JOB_ID'] || # Gitlab Release 9.0+
          ENV['CI_BUILD_ID']  # Gitlab Release 8.x
        end

        def commit_hash
          ENV['CI_COMMIT_SHA'] || # Gitlab Release 9.0+
          ENV['CI_BUILD_REF'] # Gitlab Release 8.x
        end

        def branch
          ENV['CI_COMMIT_REF_NAME'] || # Gitlab Release 9.0+
          ENV['CI_BUILD_REF_NAME'] # Gitlab Release 8.x
        end

        def project_dir
          ENV['CI_PROJECT_DIR']
        end
      end
    end
  end
end
