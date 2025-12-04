# frozen_string_literal: true

module KnapsackPro
  module TestCaseMergers
    class RSpecMerger
      def initialize(test_files)
        @test_files = test_files
      end

      def call
        file_paths = {}
        id_paths = {}

        @test_files.each do |test_file|
          raw_path = test_file.fetch('path')
          file_path = KnapsackPro::Adapters::RSpecAdapter.parse_file_path(raw_path)

          if KnapsackPro::Adapters::RSpecAdapter.id_path?(raw_path)
            id_paths[file_path] ||= 0.0
            id_paths[file_path] += test_file.fetch('time_execution')
          else
            file_paths[file_path] = test_file.fetch('time_execution') # may be nil
          end
        end

        file_paths
          .merge(id_paths) { |_, v1, v2| [v1, v2].compact.max }
          .map do |file_path, time_execution|
            { 'path' => file_path, 'time_execution' => time_execution }
          end
      end
    end
  end
end
