describe KnapsackPro do
  describe '.load_tasks' do
    let(:task_loader) { instance_double(KnapsackPro::TaskLoader) }

    it do
      expect(KnapsackPro::TaskLoader).to receive(:new).and_return(task_loader)
      expect(task_loader).to receive(:load_tasks)
      described_class.load_tasks
    end
  end
end
