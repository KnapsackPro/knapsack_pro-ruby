# Description

TODO

# Checks

- [ ] I added the changes to the `UNRELEASED` section of the `CHANGELOG.md`, including the needed bump (i.e., patch, minor, major)
- [ ] I followed the architecture outlined below for RSpec in Queue Mode:
  - Pure: `lib/knapsack_pro/pure/queue/rspec_pure.rb` contains pure functions that are unit tested.
  - Extension: `lib/knapsack_pro/extensions/rspec_extension.rb` encapsulates calls to RSpec internals and is integration and E2E tested.
  - Runner: `lib/knapsack_pro/runners/queue/rspec_runner.rb` invokes the pure code and the extension to produce side effects, which are integration and E2E tested.
