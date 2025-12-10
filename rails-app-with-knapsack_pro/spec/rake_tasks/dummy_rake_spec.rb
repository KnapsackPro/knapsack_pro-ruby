describe 'Dummy rake' do
  describe "dummy:do_something_once" do
    let(:task_name) { "dummy:do_something_once" }
    let(:task) { Rake::Task[task_name] }

    context 'when Rake.application.rake_require is used to load the rake task' do
      before do
        Rake.application.rake_require("tasks/dummy")
        Rake::Task.define_task(:environment)
      end

      after do
        Rake::Task[task_name].reenable

        DummyOutput.count = 0
      end

      2.times do
        it "calls the rake task (increases counter by one)" do
          expect { task.invoke }.to_not raise_error
          expect(DummyOutput.count).to eq(1)
        end
      end
    end
  end
end
