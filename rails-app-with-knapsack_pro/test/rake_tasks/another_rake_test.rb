require 'test_helper'

class AnotherDummyRakeTest < ActiveSupport::TestCase
  setup do # before(:all)
    @@setup ||= begin
      Rake.load_rakefile("tasks/another_dummy.rake")
      Rake::Task.define_task(:environment)
    end
  end

  teardown do
    Rake::Task["another_dummy:do_something_once"].reenable
    AnotherDummyOutput.count = 0
  end

  test "calls the rake task (increases counter by one)" do
    2.times do
      Rake::Task["another_dummy:do_something_once"].invoke
      assert_equal 1, AnotherDummyOutput.count
    end
  end
end
