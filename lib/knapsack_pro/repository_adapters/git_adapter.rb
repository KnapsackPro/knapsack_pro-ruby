module KnapsackPro
  module RepositoryAdapters
    class GitAdapter
      class << self
        def credentials
          @credentials ||= KnapsackPro::Credentials.new(:git_working_dir)
        end
      end

      def initialize
        @git = Git.open(working_dir)
      end

      def commit_hash
        git.gcommit('HEAD').sha
      end

      def branch
        git.branch.name
      end

      private

      attr_reader :git

      def credentials
        self.class.credentials.get
      end

      def working_dir
        credentials[:git_working_dir]
      end
    end
  end
end
