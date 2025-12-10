if defined?(KnapsackPro)
  module KnapsackPro
    module RepositoryAdapters
      module GitAdapterPatch
        # an example method to patch
        #def git_commit_authors
          #`git log --since "one month ago" 2>/dev/null | git shortlog --summary --email 2>/dev/null`
        #end
      end
    end
  end

  KnapsackPro::RepositoryAdapters::GitAdapter.prepend(KnapsackPro::RepositoryAdapters::GitAdapterPatch)
end
