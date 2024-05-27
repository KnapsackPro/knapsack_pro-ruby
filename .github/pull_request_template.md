# Story

TODO: link to the internal story

## Related

TODO: links to related PRs or issues

# Description

TODO

# Changes

TODO: changes introduced by this PR

# Checklist reminder

- [ ] You added the changes to the `UNRELEASED` section of the `CHANGELOG.md`, including the needed bump (ie, patch, minor, major)
- [ ] You follow the architecture outlined below for RSpec in Queue Mode, which is a work in progress (feel free to propose changes):
  - Pure: `lib/knapsack_pro/pure/queue/rspec_pure.rb` contains pure functions that are unit tested.
  - Extension: `lib/knapsack_pro/extensions/rspec_extension.rb` encapsulates calls to RSpec internals and is integration and e2e tested.
  - Runner: `lib/knapsack_pro/runners/queue/rspec_runner.rb` invokes the pure code and the extension to produce side effects, which are integration and e2e tested.
