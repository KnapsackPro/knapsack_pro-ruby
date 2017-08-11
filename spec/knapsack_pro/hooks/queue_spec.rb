describe KnapsackPro::Hooks::Queue do
  describe '.call_before_queue' do
    subject { described_class.call_before_queue }

    context 'when callback is not set' do
      before do
        described_class.reset_before_queue
      end

      it { should be_nil }
    end

    context 'when callback is set' do
      let(:queue_id) { double }

      before do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).and_return(queue_id)

        described_class.before_queue do |q_id|
          [:fake_value, q_id]
        end
      end

      it { should eq [:fake_value, queue_id] }
    end
  end

  describe '.call_after_subset_queue' do
    subject { described_class.call_after_subset_queue }

    context 'when callback is not set' do
      before do
        described_class.reset_after_subset_queue
      end

      it { should be_nil }
    end

    context 'when callback is set' do
      let(:queue_id) { double }
      let(:subset_queue_id) { double }

      before do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).and_return(queue_id)
        expect(KnapsackPro::Config::Env).to receive(:subset_queue_id).and_return(subset_queue_id)

        described_class.after_subset_queue do |q_id, subset_q_id|
          [:fake_value, q_id, subset_q_id]
        end
      end

      it { should eq [:fake_value, queue_id, subset_queue_id] }
    end
  end

  describe '.call_after_queue' do
    subject { described_class.call_after_queue }

    context 'when callback is not set' do
      before do
        described_class.reset_after_queue
      end

      it { should be_nil }
    end

    context 'when callback is set' do
      let(:queue_id) { double }

      before do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).and_return(queue_id)

        described_class.after_queue do |q_id|
          [:fake_value, q_id]
        end
      end

      it { should eq [:fake_value, queue_id] }
    end
  end
end
