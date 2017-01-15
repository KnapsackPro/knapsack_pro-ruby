module KnapsackPro
  module Config
    module CI
      class Circle < Base
        def node_total
          ENV['CIRCLE_NODE_TOTAL']
        end

        def node_index
          ENV['CIRCLE_NODE_INDEX']
        end

        def node_build_id
          ENV['CIRCLE_BUILD_NUM']
        end

        def commit_hash
          ENV['CIRCLE_SHA1']
        end

        def branch
          ENV['CIRCLE_BRANCH']
        end

        def project_dir
          project_repo_name = ENV['CIRCLE_PROJECT_REPONAME']
          "/home/ubuntu/#{project_repo_name}" if project_repo_name
        end
      end
    end
  end
end
