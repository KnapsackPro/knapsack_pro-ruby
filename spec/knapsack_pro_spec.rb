require 'tmpdir'

describe KnapsackPro do
  describe '.root' do
    subject { described_class.root }

    it { expect(subject).to match 'knapsack_pro-ruby' }
  end

  describe '.logger' do
    subject { described_class.logger }

    before(:each) do
      described_class.reset_logger!
      KnapsackPro::Config::Env.remove_instance_variable(:@ci_node_index) if KnapsackPro::Config::Env.instance_variable_defined?(:@ci_node_index)
    end

    after { described_class.reset_logger! }

    context 'when KNAPSACK_PRO_LOG_DIR is set' do
      context 'when KNAPSACK_PRO_CI_NODE_INDEX is set' do
        it 'logs to a file in that dir named after the node index' do
          Dir.mktmpdir do |dir|
            stub_const('ENV', 'KNAPSACK_PRO_LOG_DIR' => dir, 'KNAPSACK_PRO_CI_NODE_INDEX' => 1)

            KnapsackPro.logger.debug 'debug'
            KnapsackPro.logger.info 'info'
            KnapsackPro.logger.warn 'warn'

            log = File.read "#{dir}/knapsack_pro_node_1.log"
            expect(log).not_to include('DEBUG -- knapsack_pro: debug')
            expect(log).to include('INFO -- knapsack_pro: info')
            expect(log).to include('WARN -- knapsack_pro: warn')
          end
        end
      end

      context 'when KNAPSACK_PRO_CI_NODE_INDEX is not set' do
        it 'logs to a file in that dir named after node index 0' do
          Dir.mktmpdir do |dir|
            stub_const('ENV', 'KNAPSACK_PRO_LOG_DIR' => dir)

            KnapsackPro.logger.debug 'debug'
            KnapsackPro.logger.info 'info'
            KnapsackPro.logger.warn 'warn'

            log = File.read "#{dir}/knapsack_pro_node_0.log"
            expect(log).not_to include('DEBUG -- knapsack_pro: debug')
            expect(log).to include('INFO -- knapsack_pro: info')
            expect(log).to include('WARN -- knapsack_pro: warn')
          end
        end
      end
    end

    context 'with the default logger' do
      it 'ignores debug to stdout' do
        expect do
          KnapsackPro.stdout = $stdout
          KnapsackPro.logger.debug 'debug'
        end
          .not_to output.to_stdout
      end

      it 'logs info to stdout' do
        expect do
          KnapsackPro.stdout = $stdout
          KnapsackPro.logger.info 'info'
        end
          .to output(/INFO -- knapsack_pro: info/)
          .to_stdout
      end

      it 'logs warn to stdout' do
        expect do
          KnapsackPro.stdout = $stdout
          KnapsackPro.logger.warn 'warn'
        end
          .to output(/WARN -- knapsack_pro: warn/)
          .to_stdout
      end
    end

    context 'with a custom logger' do
      it 'logs using it' do
        stream = StringIO.new
        KnapsackPro.logger = ::Logger.new(stream)

        KnapsackPro.logger.debug 'debug'
        KnapsackPro.logger.info 'info'
        KnapsackPro.logger.warn 'warn'

        expect(stream.string).to include('DEBUG -- knapsack_pro: debug')
        expect(stream.string).to include('INFO -- knapsack_pro: info')
        expect(stream.string).to include('WARN -- knapsack_pro: warn')
      end
    end
  end

  describe '.tracker' do
    subject { described_class.tracker }

    it { should be_a KnapsackPro::Tracker }
    it { expect(subject.object_id).to eql described_class.tracker.object_id }
  end

  describe '.load_tasks' do
    let(:task_loader) { instance_double(KnapsackPro::TaskLoader) }

    it do
      expect(KnapsackPro::TaskLoader).to receive(:new).and_return(task_loader)
      expect(task_loader).to receive(:load_tasks)
      described_class.load_tasks
    end
  end
end
