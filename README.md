# `knapsack_pro` ruby gem

<p align="center">
  <a href="https://knapsackpro.com?utm_source=github&utm_medium=readme&utm_campaign=knapsack_pro-ruby_gem&utm_content=hero_logo">
    <img alt="Knapsack Pro" src="./.github/assets/knapsack-diamonds.png" width="300" height="300" style="max-width: 100%;" />
  </a>
</p>

<h3 align="center">Speed up your tests</h3>
<p align="center">Run your 1-hour test suite in 2 minutes with optimal parallelisation on your existing CI infrastructure</p>

---

<div align="center">
  <a href="https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby">
    <img alt="Circle CI" src="https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby.svg" />
  </a>
  <a href="https://rubygems.org/gems/knapsack_pro">
    <img alt="Gem Version" src="https://badge.fury.io/rb/knapsack_pro.svg" />
  </a>
</div>

<br />
<br />

Knapsack Pro wraps your current test runner(s) and works with your existing CI infrastructure to parallelize tests optimally:

- Dynamically splits your tests based on up-to-date test execution data
- Is designed from the ground up for CI and supports all of them
- Tracks your CI builds to detect bottlenecks
- Does not have access to your source code and collects minimal test data (with opt-in encryption)
- Enables you to export historical metrics about your CI builds
- Supports out-of-the-box any Ruby test runners, Cypress, Jest (and provides both SDK and API to integrate with any other language)
- Replaces local dependencies like Redis with an API and runs your tests regardless of network problems

The `knapsack_pro` gem supports all CIs and the following test runners:

- RSpec
- Cucumber
- Minitest
- test-unit
- Spinach
- Turnip

## Installation

The [Installation Guide](https://docs.knapsackpro.com/knapsack_pro-ruby/guide/?utm_source=github&utm_medium=readme&utm_campaign=knapsack_pro-ruby_gem&utm_content=installation_guide) will ask you a few questions and generate instruction steps for your project:

<div align="center">
  <a href="https://docs.knapsackpro.com/knapsack_pro-ruby/guide/?utm_source=github&utm_medium=readme&utm_campaign=knapsack_pro-ruby_gem&utm_content=installation_guide">
    <img alt="Install button" src="./.github/assets/install-button.png" width="116" height="50" />
  </a>
</div>

## Upgrade

Knapsack Pro follows semantic versioning, but make sure to check the [changelog](CHANGELOG.md) before updating gem with:

```bash
bundle update knapsack_pro
```

## Contributing

### Testing

RSpec:

```bash
bin/test
```

Scripted tests can be found in the [Rails App With Knapsack Pro repository](https://github.com/KnapsackPro/rails-app-with-knapsack_pro/blob/master/bin/knapsack_pro_all.rb).

### Publishing

1. Move the changes listed in the `UNRELEASED` section of the `CHANGELOG.md` to the proper version

2. Update the gem version in `lib/knapsack_pro/version.rb`

3. `git commit -am "Bump version x.x.x"`

4. Build, tag, push, release: `bundle exec rake release`

5. Update the latest available gem version in `TestSuiteClientVersionChecker` for the Knapsack Pro API repository.

6. Update the `knapsack_pro` gem version in:

- [Rails App With Knapsack Pro repository](https://github.com/KnapsackPro/rails-app-with-knapsack_pro)
- Knapsack Pro API internal repository
