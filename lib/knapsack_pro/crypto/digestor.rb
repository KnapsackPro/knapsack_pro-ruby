module KnapsackPro
  module Crypto
    class Digestor
      def self.salt_hexdigest(path)
        salt = KnapsackPro::Config::Env.salt
        str = salt + path
        Digest::SHA2.hexdigest(str)
      end
    end
  end
end
