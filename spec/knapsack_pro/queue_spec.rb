describe KnapsackPro::Queue do
  it 'simulates a Queue Mode build' do
    queue = described_class.new

    expect(queue.current_batch).to be_nil

    # 1st batch
    test_files_paths_1 = ['a_spec.rb', 'b_spec.rb']
    queue.add_batch_for(test_files_paths_1)

    expect(queue.current_batch.test_file_paths).to eq(['a_spec.rb', 'b_spec.rb'])
    expect(queue.current_batch.status).to eq :not_executed
    queue.mark_batch_passed
    expect(queue.current_batch.status).to eq :passed


    # 2nd batch
    test_files_paths_2 = ['c_spec.rb', 'd_spec.rb']
    queue.add_batch_for(test_files_paths_2)

    expect(queue.current_batch.test_file_paths).to eq(['c_spec.rb', 'd_spec.rb'])
    expect(queue.current_batch.status).to eq :not_executed
    queue.mark_batch_failed
    expect(queue.current_batch.status).to eq :failed


    # last batch from the Queue API is always empty
    test_files_paths_3 = []
    queue.add_batch_for(test_files_paths_3)

    expect(queue.size).to eq 2
    expect(queue[0].status).to eq :passed
    expect(queue[1].status).to eq :failed
  end
end
