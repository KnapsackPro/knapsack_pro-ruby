# frozen_string_literal: true

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
        if KnapsackPro::Config::Env.ci? && shallow_repository?
          command = 'git fetch --shallow-since "one month ago" --quiet'
          begin
            Timeout.timeout(5) do
              Kernel.system(command, out: File::NULL, err: File::NULL)
            end
          rescue Timeout::Error
            KnapsackPro.logger.debug("Skip the `#{command}` command because it took too long.")
          end
        end

        summary_read, log_write = IO.pipe
        Kernel.system('git log --since "one month ago"', out: log_write, err: File::NULL)
        log_write.close
        summary, summary_write = IO.pipe
        Kernel.system('git shortlog --summary --email', in: summary_read, out: summary_write, err: File::NULL)
        summary_write.close
        summary.read
      end

      def git_build_author
        r, w = IO.pipe
        Kernel.system('git log --format="%aN <%aE>" -1', out: w, err: File::NULL)
        w.close
        r.read
      end

      def shallow_repository?
        r, w = IO.pipe
        Kernel.system('git rev-parse --is-shallow-repository', out: w, err: File::NULL)
        w.close
        r.read.strip == 'true'
      end

      def working_dir
        dir = KnapsackPro::Config::Env.project_dir
        File.expand_path(dir)
      end
    end
  end
end
