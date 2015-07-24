module KnapsackPro
  module Client
    module API
      class Action
        attr_reader :endpoint_path, :http_method, :request_hash

        def initialize(endpoint_path:,
                       http_method:,
                       request_hash:)
          @endpoint_path = endpoint_path
          @http_method = http_method
          @request_hash = request_hash
        end
      end
    end
  end
end
