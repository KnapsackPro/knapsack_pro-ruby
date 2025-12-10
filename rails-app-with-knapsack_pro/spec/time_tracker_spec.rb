# Needed to reproduce the issue:
# https://github.com/KnapsackPro/knapsack_pro-ruby/pull/265
require 'spec_helper'

describe "Verify KnapsackPro::Formatters::TimeTracker works for Regular Mode in the knapsack_pro gem when the .rspec file does not exist (it does not load spec_helper by default at RSpec start), but spec_helper is loaded later after this spec is loaded (note there is require 'spec_helper' at the top). This spec must be run as part of the CI pipeline in the knapsack_pro gem" do
  it do
    expect(true).to be true
  end
end
