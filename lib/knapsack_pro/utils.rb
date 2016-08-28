module KnapsackPro
  class Utils
    def self.unsymbolize(hash)
      JSON.parse(hash.to_json)
    end
  end
end
