module KnapsackPro
  module Client
    module API
      module V1
        class BuildDistributions < Base
          CODE_ATTEMPT_TO_READ_FROM_CACHE_CANCELED = 'ATTEMPT_TO_READ_FROM_CACHE_CANCELED'

          class << self
            def subset(args)
              request_hash = {
                :fixed_test_suite_split => KnapsackPro::Config::Env.fixed_test_suite_split,
                :attempt_to_read_from_cache => args.fetch(:attempt_to_read_from_cache),
                :commit_hash => args.fetch(:commit_hash),
                :branch => args.fetch(:branch),
                :node_total => args.fetch(:node_total),
                :node_index => args.fetch(:node_index),
                :ci_build_id => KnapsackPro::Config::Env.ci_node_build_id,
              }

              unless request_hash[:attempt_to_read_from_cache]
                request_hash.merge!({
                  :test_files => args.fetch(:test_files)
                })
              end

              action_class.new(
                endpoint_path: '/v1/build_distributions/subset',
                http_method: :post,
                request_hash: request_hash
              )
            end

            def last(args)
              action_class.new(
                endpoint_path: '/v1/build_distributions/last',
                http_method: :get,
                request_hash: {
                  :commit_hash => args.fetch(:commit_hash),
                  :branch => args.fetch(:branch),
                  :node_total => args.fetch(:node_total),
                  :node_index => args.fetch(:node_index),
                }
              )
            end
          end
        end
      end
    end
  end
end
