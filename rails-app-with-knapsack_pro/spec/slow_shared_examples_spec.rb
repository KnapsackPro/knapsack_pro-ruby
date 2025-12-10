RSpec.shared_context "shared stuff", :shared_context => :metadata do
  before do
    sleep 1
    sleep ENV['EXTRA_TEST_FILES_DELAY'].to_i
  end
end

describe 'Example of slow shared examples' do
  # this should add 1s for each it below including
  # shared example.
  include_context "shared stuff"

  # this should add 1.5s to the total timing of this test file recorded by knapsack_pro
  # 1.5s + 1s from include_context
  it_behaves_like 'slow shared example test'


  # ~0.001s + 1s from include_context
  it do
    expect(true).to be true
  end

  # in total this file should take ~3.5s
end
