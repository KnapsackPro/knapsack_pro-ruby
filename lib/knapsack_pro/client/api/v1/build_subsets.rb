module KnapsackPro
  module Client
    module API
      module V1
        class BuildSubsets < Base
          class << self
            def create(commit_hash:,
                       branch:,
                       node_total:,
                       node_index:,
                       test_files:)
              action_class.new(
                endpoint_path: '/v1/build_subsets',
                http_method: :post,
                request_hash: {
                  :commit_hash => commit_hash,
                  :branch => branch,
                  :node_total => node_total,
                  :node_index => node_index,
                  :test_files => test_files
                }
              )
            end
          end
        end
      end
    end
  end
end
