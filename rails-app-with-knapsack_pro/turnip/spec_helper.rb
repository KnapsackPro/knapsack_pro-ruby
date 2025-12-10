require "knapsack_pro"
KnapsackPro::Adapters::RSpecAdapter.bind

module FooSteps
  step "I have a two" do
    @input = 2
  end

  step "I add one" do
    @input += 1
  end

  step "I expect a three" do
    expect(@input).to eq 3
  end
end

RSpec.configure { |c| c.include FooSteps }
