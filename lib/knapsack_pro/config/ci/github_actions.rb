# frozen_string_literal: true

# https://docs.github.com/en/actions/reference/workflows-and-actions/variables
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
          # A unique number for each run within a repository. This number does not change if you re-run the workflow run.
          ENV['GITHUB_RUN_ID']
        end

        def node_retry_count
          # A unique number for each attempt of a particular workflow run in a repository.
          # This number begins at 1 for the workflow run's first attempt, and increments with each re-run.
          run_attempt = ENV['GITHUB_RUN_ATTEMPT']
          return unless run_attempt
          run_attempt.to_i - 1
        end

        def commit_hash
          ENV['GITHUB_SHA']
        end

        def branch
          # `on: push` has `GITHUB_HEAD_REF=`
          head_ref = ENV.fetch('GITHUB_HEAD_REF', '')
          return head_ref unless head_ref == ''

          ENV['GITHUB_REF_NAME'] || ENV['GITHUB_SHA']
        end

        def project_dir
          ENV['GITHUB_WORKSPACE']
        end

        def user_seat
          ENV['GITHUB_ACTOR']
        end

        def detected
          ENV.key?('GITHUB_ACTIONS') ? self.class : nil
        end

        def fixed_queue_split
          true
        end

        def ci_provider
          "GitHub Actions"
        end
      end
    end
  end
end
