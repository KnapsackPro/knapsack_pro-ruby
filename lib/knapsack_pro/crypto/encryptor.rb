module KnapsackPro
  module Crypto
    class Encryptor
      def initialize(test_files)
        @test_files = test_files
      end

      def call
        encrypted_test_files = []

        test_files.each do |test_file|
          test_file_dup = test_file.dup
          test_file_dup[:path] = Digestor.salt_hexdigest(test_file[:path])
          encrypted_test_files << test_file_dup
        end

        encrypted_test_files
      end

      private

      attr_reader :test_files
    end
  end
end
