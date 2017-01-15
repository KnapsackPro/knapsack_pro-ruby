module KnapsackPro
  module Config
    module CI
      class Travis < Base
        def node_build_id
          ENV['TRAVIS_BUILD_NUMBER']
        end

        def commit_hash
          ENV['TRAVIS_COMMIT']
        end

        def branch
          ENV['TRAVIS_BRANCH']
        end

        def project_dir
          ENV['TRAVIS_BUILD_DIR']
        end
      end
    end
  end
end
