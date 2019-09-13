# https://help.github.com/en/articles/virtual-environments-for-github-actions#environment-variables
module KnapsackPro
  module Config
    module CI
      class GithubActions < Base
        def node_total
          # not provided
        end

        def node_index
          # not provided
        end

        def node_build_id
          # not provided
        end

        def commit_hash
          ENV['GITHUB_SHA']
        end

        def branch
          # GITHUB_REF - The branch or tag ref that triggered the workflow. For example, refs/heads/feature-branch-1.
          # If neither a branch or tag is available for the event type, the variable will not exist.
          ENV['GITHUB_REF'] || ENV['GITHUB_SHA']
        end

        def project_dir
          ENV['GITHUB_WORKSPACE']
        end
      end
    end
  end
end
