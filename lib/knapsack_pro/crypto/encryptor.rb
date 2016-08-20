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
          test_file_dup[:path] = encrypt(test_file[:path])
          encrypted_test_files << test_file_dup
        end

        encrypted_test_files
      end

      private

      attr_reader :test_files

      def encrypt(path)
        Digest::SHA2.hexdigest(salt + path)
      end

      def salt
        KnapsackPro::Config::Env.salt
      end
    end
  end
end
