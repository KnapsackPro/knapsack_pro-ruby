module KnapsackPro
  module Config
    class TempFiles
      def self.temp_directory_path
        temp_files = new
        temp_files.ensure_temp_directory_exists
        temp_files.temp_directory_path
      end

      def ensure_temp_directory_exists
        unless File.exists?(gitignore_file_path)
          create_temp_directory
          create_gitignore_file
        end
      end

      def temp_directory_path
        File.join(KnapsackPro.root, '.knapsack_pro')
      end

      private

      def create_temp_directory
        FileUtils.mkdir_p(temp_directory_path)
      end

      def gitignore_file_path
        File.join(temp_directory_path, '.gitignore')
      end

      def gitignore_file_content
        "# This directory is used by knapsack_pro gem for temporary files during tests runtime.\n" <<
        "# Ignore all files, and do not commit this directory into your repository.\n" <<
        "# Learn more at https://knapsackpro.com\n" <<
        "*"
      end

      def create_gitignore_file
        File.open(gitignore_file_path, 'w+') do |f|
          f.write(gitignore_file_content)
        end
      end
    end
  end
end
