# https://github.com/KnapsackPro/knapsack/pull/107
describe 'Track context time' do
  context 'when something' do
    before(:context) do
      sleep(2)
    end

    after(:context) do
      sleep(3)
    end

    before do
      sleep(0.1)
    end

    it 'test 1' do
      sleep(0.2)
      expect(true).to be_truthy
    end

    it 'test 2' do
      sleep(0.3)
      expect(true).to be_truthy
    end
  end
end
