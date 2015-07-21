module KnapsackPro
  module Client
    module API
      module V1
        class BuildDistributions
          class << self
            def subset
              {
                'commit_hash' => '123',
                'branch' => 'master',
                'node_total' => '2',
                'node_index' => '1',
                'test_files' => [
                  {
                    'path' => 'a_spec.rb'
                  },
                  {
                    'path' => 'b_spec.rb'
                  }
                ]
              }
            end
          end
        end
      end
    end
  end
end
