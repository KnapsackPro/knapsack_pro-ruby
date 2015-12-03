module KnapsackPro
  class LoggerWrapper
    def initialize(logger)
      @logger = logger
    end

    private

    attr_reader :logger

    def method_missing(m, *args, &block)
      args[0] = "[knapsack_pro] #{args[0]}"
      logger.send(m, *args, &block)
    end
  end
end
