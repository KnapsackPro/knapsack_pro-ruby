# frozen_string_literal: true

module KnapsackPro
  module Client
    module API
      Action = Struct.new(:endpoint_path, :http_method, :request_hash, keyword_init: true)
    end
  end
end
