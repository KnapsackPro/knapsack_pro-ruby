# We on purpose slown down each test by 1s.
# We expect to see the file to took ~3s in knapsack pro dashboard.
# This way we can validate if the ActiveSupport::Testing::TimeHelpers
# have impact on the way how knapsack_pro measures the timing for tests.
describe 'Time travel with ActiveSupport::Testing::TimeHelpers' do
  context 'travel_back' do
    before { travel_to Time.new(2004, 11, 24, 01, 04, 44) }
    after { travel_back }

    it do
      sleep 1

      expect(Time.current.year).to eq 2004
      expect(Time.now.year).to eq 2004
    end
  end

  context 'travel_to block' do
    let!(:yesterday) { 1.day.ago }

    it do
      travel_to(1.day.ago) do
        sleep 1

        expect(Time.current.day).to eq yesterday.day
      end
    end
  end

  context 'travel_to block 2014' do
    let!(:time_2014) { Time.new(2004, 11, 24, 01, 04, 44) }

    it do
      travel_to(time_2014) do
        sleep 1

        expect(Time.current.year).to eq 2004
      end
    end
  end
end
