module KnapsackPro
  class Credentials
    attr_reader :keys

    def initialize(*keys)
      @keys = keys
    end

    def get
      if @credentials && valid?(@credentials)
        @credentials
      elsif valid?(default_credentials)
        @credentials = default_credentials
      else
        raise ArgumentError.new("Missing credentials. Provide keys: #{keys}")
      end
    end

    def set=(credentials)
      @credentials ||= {}
      keys.each do |key|
       value = credentials[key]
       if value
         @credentials[key] = value
       else
         raise ArgumentError.new("Missing key #{key}.")
       end
      end
    end

    def set_default
      @credentials = default_credentials
    end

    private

    def default_credentials
      default_credentials = {}
      keys.each do |key|
        default_credentials[key] = ENV["KNAPSACK_PRO_#{key.to_s.upcase}"]
      end
      default_credentials
    end

    def valid?(credentials)
      !credentials.values.any? { |value| value.nil? }
    end
  end
end
