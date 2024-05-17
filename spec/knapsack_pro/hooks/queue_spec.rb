describe KnapsackPro::Hooks::Queue do
  describe '.call_before_queue' do
    subject { described_class.call_before_queue }

    before do
      described_class.reset_before_queue
    end

    context 'when no callback is set' do
      it { should be_nil }
    end

    context 'when multiple callbacks are set' do
      let(:queue_id) { double }

      it 'calls each block' do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).twice.and_return(queue_id)

        expected_called_blocks = []

        described_class.before_queue do |q_id|
          expected_called_blocks << [:block_1_called, q_id]
        end
        described_class.before_queue do |q_id|
          expected_called_blocks << [:block_2_called, q_id]
        end

        subject

        expect(expected_called_blocks).to eq([
          [:block_1_called, queue_id],
          [:block_2_called, queue_id],
        ])
      end
    end
  end

  describe '.call_before_subset_queue' do
    subject { described_class.call_before_subset_queue }

    before do
      described_class.reset_before_subset_queue
    end

    context 'when no callback is set' do
      it { should be_nil }
    end

    context 'when multiple callbacks are set' do
      let(:queue_id) { double }
      let(:subset_queue_id) { double }

      it 'calls each block' do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).twice.and_return(queue_id)
        expect(KnapsackPro::Config::Env).to receive(:subset_queue_id).twice.and_return(subset_queue_id)

        expected_called_blocks = []

        described_class.before_subset_queue do |q_id, subset_q_id|
          expected_called_blocks << [:block_1_called, q_id, subset_q_id]
        end
        described_class.before_subset_queue do |q_id, subset_q_id|
          expected_called_blocks << [:block_2_called, q_id, subset_q_id]
        end

        subject

        expect(expected_called_blocks).to eq([
          [:block_1_called, queue_id, subset_queue_id],
          [:block_2_called, queue_id, subset_queue_id],
        ])
      end
    end

    context 'when a callback is set AND the queue is passed' do
      let(:queue_id) { double }
      let(:subset_queue_id) { double }
      let(:queue) { instance_double(KnapsackPro::Queue) }

      subject { described_class.call_before_subset_queue(queue) }

      it 'calls each block' do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).and_return(queue_id)
        expect(KnapsackPro::Config::Env).to receive(:subset_queue_id).and_return(subset_queue_id)

        expected_called_blocks = []

        described_class.before_subset_queue do |q_id, subset_q_id, queue|
          expected_called_blocks << [:block_1_called, q_id, subset_q_id, queue]
        end

        subject

        expect(expected_called_blocks).to eq([
          [:block_1_called, queue_id, subset_queue_id, queue],
        ])
      end
    end
  end

  describe '.call_after_subset_queue' do
    subject { described_class.call_after_subset_queue }

    before do
      described_class.reset_after_subset_queue
    end

    context 'when no callback is set' do
      it { should be_nil }
    end

    context 'when multiple callbacks are set' do
      let(:queue_id) { double }
      let(:subset_queue_id) { double }

      it 'calls each block' do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).at_least(:once).and_return(queue_id)
        expect(KnapsackPro::Config::Env).to receive(:subset_queue_id).at_least(:once).and_return(subset_queue_id)

        expected_called_blocks = []

        described_class.after_subset_queue do |q_id, subset_q_id|
          expected_called_blocks << [:block_1_called, q_id, subset_q_id]
        end
        described_class.after_subset_queue do |q_id, subset_q_id|
          expected_called_blocks << [:block_2_called, q_id, subset_q_id]
        end

        subject

        expect(expected_called_blocks).to eq([
          [:block_1_called, queue_id, subset_queue_id],
          [:block_2_called, queue_id, subset_queue_id],
        ])
      end
    end

    context 'when a callback is set AND the queue is passed' do
      let(:queue_id) { double }
      let(:subset_queue_id) { double }
      let(:queue) { instance_double(KnapsackPro::Queue) }

      subject { described_class.call_after_subset_queue(queue) }

      it 'calls each block' do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).and_return(queue_id)
        expect(KnapsackPro::Config::Env).to receive(:subset_queue_id).and_return(subset_queue_id)

        expected_called_blocks = []

        described_class.after_subset_queue do |q_id, subset_q_id, queue|
          expected_called_blocks << [:block_1_called, q_id, subset_q_id, queue]
        end

        subject

        expect(expected_called_blocks).to eq([
          [:block_1_called, queue_id, subset_queue_id, queue],
        ])
      end
    end
  end

  describe '.call_after_queue' do
    subject { described_class.call_after_queue }

    before do
      described_class.reset_after_queue
    end

    context 'when no callback is set' do
      it { should be_nil }
    end

    context 'when multiple callbacks are set' do
      let(:queue_id) { double }

      it 'calls each block' do
        expect(KnapsackPro::Config::Env).to receive(:queue_id).twice.and_return(queue_id)

        expected_called_blocks = []

        described_class.after_queue do |q_id|
          expected_called_blocks << [:block_1_called, q_id]
        end
        described_class.after_queue do |q_id|
          expected_called_blocks << [:block_2_called, q_id]
        end

        subject

        expect(expected_called_blocks).to eq([
          [:block_1_called, queue_id],
          [:block_2_called, queue_id],
        ])
      end
    end
  end
end
