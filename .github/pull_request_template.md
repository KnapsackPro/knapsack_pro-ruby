# Story

TODO: link to the internal story

## Related

TODO: links to related PRs or issues

# Description

TODO

# Changes

TODO: changes introduced by this PR

# Checklist reminder

- [ ] I follow the architecture outlined below for RSpec in Queue Mode:
  - The test runner core contains pure functions that are unit tested.
  - Test runner extensions encapsulate calls to RSpec internals and are integration and e2e tested.
  - The test runner invokes the core and the extensions to produce side effects, which are integration and e2e tested.
