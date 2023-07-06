module KnapsackPro
  module RepositoryAdapters
    class GitAdapter < BaseAdapter
      def commit_hash
        `git -C "#{working_dir}" rev-parse HEAD`.strip
      end

      def branch
        `git -C "#{working_dir}" rev-parse --abbrev-ref HEAD`.strip
      end

      def branches
        str_branches = `git rev-parse --abbrev-ref --branches`
        str_branches.split("\n")
      end

      def commit_authors
        authors = git_commit_authors
          .split("\n")
          .map { |line| line.strip }
          .map { |line| line.split("\t") }
          .map do |commits, author|
            { commits: commits.to_i, author: KnapsackPro::MaskString.call(author) }
          end

        raise if authors.empty?

        authors
      rescue Exception
        []
      end

      def build_author
        author = KnapsackPro::MaskString.call(git_build_author.strip)
        raise if author.empty?
        author
      rescue Exception
        "no git <no.git@example.com>"
      end

      private

      def git_commit_authors
        `git fetch --shallow-since "1 month ago" >/dev/null 2>&1 && git shortlog --summary --email --since "one month ago"`
      end

      def git_build_author
        `git log --format="%aN <%aE>" -1`
      end

      def working_dir
        dir = KnapsackPro::Config::Env.project_dir
        File.expand_path(dir)
      end
    end
  end
end
