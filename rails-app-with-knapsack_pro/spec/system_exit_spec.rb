describe 'SystemExit' do
  it do
    expect(true).to be true
  end

  # uncomment this exception to test scenario when RSpec raises an exception
  # and Knapsack Pro should catch it and call the Knapsack Pro Queue Mode hooks
  # More: https://github.com/KnapsackPro/knapsack_pro-ruby/pull/214
  #raise SystemExit
end
