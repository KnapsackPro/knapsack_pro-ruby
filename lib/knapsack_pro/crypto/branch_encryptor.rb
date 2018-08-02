module KnapsackPro
  module Crypto
    class BranchEncryptor
      NON_ENCRYPTABLE_BRANCHES = %w(develop development dev master staging)

      def self.call(branch)
        if KnapsackPro::Config::Env.branch_encrypted?
          new(branch).call
        else
          branch
        end
      end

      def initialize(branch)
        @branch = branch
      end

      def call
        if NON_ENCRYPTABLE_BRANCHES.include?(branch)
          branch
        else
          Digestor.salt_hexdigest(branch)[0..6]
        end
      end

      private

      attr_reader :branch
    end
  end
end
