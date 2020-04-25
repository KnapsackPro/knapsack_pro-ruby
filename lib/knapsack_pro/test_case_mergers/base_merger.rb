module KnapsackPro
  module TestCaseMergers
    class BaseMerger
      def self.call(adapter_class, test_files)
        merger_class =
          case adapter_class
          when KnapsackPro::Adapters::RSpecAdapter
            KnapsackPro::TestCaseMergers::RSpecMerger
          else
            raise "Test case merger does not exist for adapter_class: #{adapter_class}"
          end
        merger_class.new(test_files).call
      end

      def initialize(test_files)
        @test_files = test_files
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :test_files
    end
  end
end
