module KnapsackPro
  module Adapters
    class BaseAdapter
      # Just example, please overwrite constant in subclass
      TEST_DIR_PATTERN = 'test/**/*_test.rb'

      def self.bind
        adapter = new
        adapter.bind
        adapter
      end

      def bind
        # TODO
      end
    end
  end
end
