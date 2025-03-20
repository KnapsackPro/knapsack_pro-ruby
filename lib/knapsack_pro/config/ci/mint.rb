# frozen_string_literal: true

module KnapsackPro
  module Config
    module CI
      class Mint < Base
        def node_total
          ENV['MINT_PARALLEL_TOTAL']
        end

        def node_index
          ENV['MINT_PARALLEL_INDEX']
        end

        def node_build_id
          ENV['MINT_RUN_ID']
        end

        def commit_hash
          ENV['MINT_GIT_COMMIT_SHA']
        end

        def branch
          ENV['MINT_GIT_REF_NAME']
        end

        def project_dir
          # not provided
        end

        def user_seat
          ENV['MINT_ACTOR_ID'] || ENV['MINT_GIT_COMMITTER_EMAIL']
        end

        def detected
          ENV.key?('MINT') ? self.class : nil
        end

        def fixed_queue_split
          true
        end

        def ci_provider
          "Mint"
        end
      end
    end
  end
end
