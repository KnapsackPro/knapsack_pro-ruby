# frozen_string_literal: true

module KnapsackPro
  module Store
    # Consumers of this class are the gem's users.
    # Ensure the API is backward compatible when introducing changes.
    class Client
      def self.batches
        client.batches
      end

      private

      def self.client
        KnapsackPro::Store::Server.client
      end
    end
  end
end
