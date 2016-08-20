module KnapsackPro
  module Crypto
    class Decryptor
      class MissingEncryptedTestFileError < StandardError; end
      class TooManyEncryptedTestFilesError < StandardError; end

      def initialize(test_files, encrypted_test_files)
        @test_files = test_files
        @encrypted_test_files = encrypted_test_files
      end

      def call
        decrypted_test_files = []

        test_files.each do |test_file|
          encrypted_path = encrypt(test_file[:path])
          encrypted_test_file = find_encrypted_test_file(encrypted_path)

          decrypted_test_file = encrypted_test_file.dup
          decrypted_test_file[:path] = test_file[:path]

          decrypted_test_files << decrypted_test_file
        end

        decrypted_test_files
      end

      private

      attr_reader :test_files,
        :encrypted_test_files

      def encrypt(path)
        Digest::SHA2.hexdigest(salt + path)
      end

      def salt
        KnapsackPro::Config::Env.salt
      end

      def find_encrypted_test_file(encrypted_path)
        test_files = encrypted_test_files.select do |t|
          t[:path] == encrypted_path
        end

        if test_files.size == 0
          raise MissingEncryptedTestFileError.new("Couldn't find encrypted test file for encrypted path #{encrypted_path}")
        elsif test_files.size == 1
          test_files.first
        else
          raise TooManyEncryptedTestFilesError.new("Found more than one encrypted test file for encrypted path #{encrypted_path}")
        end
      end
    end
  end
end
