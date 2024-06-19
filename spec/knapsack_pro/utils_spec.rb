describe KnapsackPro::Utils do
  describe '.unsymbolize' do
    let(:test_files) do
      [
        { path: 'a_spec.rb', time_execution: 0.1 },
        { path: 'b_spec.rb', time_execution: 0.2 },
      ]
    end

    subject { described_class.unsymbolize(test_files) }

    it do
      should eq([
        { 'path' => 'a_spec.rb', 'time_execution' => 0.1 },
        { 'path' => 'b_spec.rb', 'time_execution' => 0.2 },
      ])
    end
  end

  describe '.time_now' do
    subject { described_class.time_now }

    context 'when Timecop does not mock the time' do
      it do
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        expect(subject).to be_within(0.001).of(now)
      end
    end

    context 'when Timecop does mock the process clock' do
      around(:example) do |ex|
        unless Gem::Version.new(Timecop::VERSION) >= Gem::Version.new('0.9.9')
          raise 'Timecop >= 0.9.9 is required to run this test. Please run: bundle update'
        end

        if Gem::Version.new(Timecop::VERSION) >= Gem::Version.new('0.9.10')
          Timecop.mock_process_clock = true
          ex.run
          Timecop.mock_process_clock = false
        else
          ex.run
        end
      end

      it do
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        time = Time.local(2020, 1, 31)
        Timecop.travel(time) do
          expect(subject).to be_within(0.001).of(now)
        end
      end
    end
  end
end
