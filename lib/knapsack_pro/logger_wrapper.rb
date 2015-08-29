module KnapsackPro
  class LoggerWrapper
    def initialize(logger)
      @logger = ::ActiveSupport::TaggedLogging.new(logger)
    end

    private

    attr_reader :logger

    def method_missing(m, *args, &block)
      logger.tagged('knapsack_pro') { logger.send(m, *args, &block) }
    end
  end
end
