module KnapsackPro
  module Client
    module API
      module V1
        class Queues < Base
          class << self
            def queue(args)
              action_class.new(
                endpoint_path: '/v1/queues/queue',
                http_method: :post,
                request_hash: {
                  :can_initialize_queue => args.fetch(:can_initialize_queue),
                  :commit_hash => args.fetch(:commit_hash),
                  :branch => args.fetch(:branch),
                  :node_total => args.fetch(:node_total),
                  :node_index => args.fetch(:node_index),
                  :node_build_id => KnapsackPro::Config::Env.ci_node_build_id,
                  :test_files => args.fetch(:test_files)
                }
              )
            end
          end
        end
      end
    end
  end
end
