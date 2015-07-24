module KnapsackPro
  module RepositoryAdapters
    class GitAdapter
      class << self
        def credentials
          @credentials ||= KnapsackPro::Credentials.new(:git_working_dir)
        end
      end

      def commit_hash
        `git -C "#{working_dir}" rev-parse HEAD`.strip
      end

      def branch
        `git -C "#{working_dir}" rev-parse --abbrev-ref HEAD`.strip
      end

      private

      def credentials
        self.class.credentials.get
      end

      def working_dir
        credentials[:git_working_dir]
      end
    end
  end
end
