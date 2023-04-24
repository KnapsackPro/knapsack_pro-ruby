module KnapsackPro
  module Config
    module CI
      class Base
        def node_total
        end

        def node_index
        end

        def node_build_id
        end

        def node_retry_count
        end

        def commit_hash
        end

        def branch
        end

        def project_dir
        end

        def user_seat_string
        end

        private

        def hexdigested(string)
          Digest::SHA2.hexdigest(string)
        end
      end
    end
  end
end
