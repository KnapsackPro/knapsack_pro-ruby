# frozen_string_literal: true

module KnapsackPro
  module Client
    module API
      module V1
        class BuildDistributions < Base
          class << self
            def last(request_hash)
              action_class.new(
                endpoint_path: '/v1/build_distributions/last',
                http_method: :get,
                request_hash: request_hash
              )
            end
          end
        end
      end
    end
  end
end
