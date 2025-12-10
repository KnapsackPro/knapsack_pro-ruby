describe 'Foo' do
  it 'Foo 1 - tag_x', :tag_x do
  end

  it 'Foo 2' do
  end

  it 'Foo 3' do
    if ENV['KNAPSACK_PRO_QUEUE_ID'] && ENV['CI']
      # slow down so the same queue can start on both CI nodes
      sleep 10
    end
    expect(true).to be true
  end
end
