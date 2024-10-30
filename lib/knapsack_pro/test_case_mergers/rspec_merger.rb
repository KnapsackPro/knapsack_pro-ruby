# frozen_string_literal: true

module KnapsackPro
  module TestCaseMergers
    class RSpecMerger < BaseMerger
      def call
        all_test_files_hash = {}
        merged_test_file_examples_hash = {}

        test_files.each do |test_file|
          path = test_file.fetch('path')
          test_file_path = extract_test_file_path(path)

          if rspec_id_path?(path)
            merged_test_file_examples_hash[test_file_path] ||= 0.0
            merged_test_file_examples_hash[test_file_path] += test_file.fetch('time_execution')
          else
            all_test_files_hash[test_file_path] = test_file.fetch('time_execution')
          end
        end

        merged_test_file_examples_hash.each do |path, time_execution|
          all_test_files_hash[path] = [time_execution, all_test_files_hash[path]].compact.max
        end

        merged_test_files = []
        all_test_files_hash.each do |path, time_execution|
          merged_test_files << {
            'path' => path,
            'time_execution' => time_execution
          }
        end
        merged_test_files
      end

      private

      # path - can be:
      # test file path: spec/a_spec.rb
      # or test example path: spec/a_spec.rb[1:1]
      def extract_test_file_path(path)
        path.gsub(/\.rb\[.+\]$/, '.rb')
      end

      def rspec_id_path?(path)
        path_with_id_regex = /.+_spec\.rb\[.+\]$/

        path&.match?(path_with_id_regex)
      end
    end
  end
end
