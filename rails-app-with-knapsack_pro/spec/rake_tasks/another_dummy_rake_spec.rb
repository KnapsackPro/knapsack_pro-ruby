describe 'Another dummy rake' do
  describe "another_dummy:do_something_once" do
    let(:task_name) { "another_dummy:do_something_once" }
    let(:task) { Rake::Task[task_name] }

    context 'when Rake.load_rakefile is used to load the rake task' do
      before(:all) do
        # Need to guard the load_rakefile because split by test examples could run the before(:all) twice.
        unless Rake::Task.task_defined?("another_dummy:do_something_once")
          Rake.load_rakefile("tasks/another_dummy.rake")
          Rake::Task.define_task(:environment)
        end
      end

      after do
        Rake::Task[task_name].reenable
        AnotherDummyOutput.count = 0
      end

      2.times do
        it "calls the rake task (increases counter by one)" do
          expect { task.invoke }.to_not raise_error
          expect(AnotherDummyOutput.count).to eq(1)
        end
      end
    end
  end
end
