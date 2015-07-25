describe KnapsackPro::Config::CI::Base do
  its(:node_total) { should be nil }
  its(:node_index) { should be nil }
  its(:commit_hash) { should be nil }
  its(:branch) { should be nil }
  its(:project_dir) { should be nil }
end
