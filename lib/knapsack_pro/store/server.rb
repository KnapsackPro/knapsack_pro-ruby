# frozen_string_literal: true

module KnapsackPro
  module Store
    class Server
      def self.start_server
        DRb.start_service('druby://localhost:0', new)
        ENV['KNAPSACK_PRO_STORE_SERVER_URI'] = DRb.uri

        #Signal.trap("INT") {
          #puts 'INT handler'
        #}

        fork do
          Signal.trap("INT") {
            puts 'INT handler in fork'
          }
          begin
            # Wait for the drb server thread to finish before exiting.
            DRb.thread.join
          rescue Interrupt
            puts "Interrupt signal catched."
          ensure
            puts "Stopping DRb service."
            DRb.stop_service
          end
        end
      end

      def get_current_time
        Time.now
      end

      def self.start_client
        # must be called at least once per process
        # https://ruby-doc.org/stdlib-2.7.0/libdoc/drb/rdoc/DRb.html
        DRb.start_service

        server_uri = ENV['KNAPSACK_PRO_STORE_SERVER_URI'] || raise("#{self} must be started first.")
        DRbObject.new_with_uri(server_uri)
      end
    end
  end
end
