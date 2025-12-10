require 'test_helper'

class DummyRakeTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require("tasks/dummy")
    Rake::Task.define_task(:environment)
  end

  teardown do
    Rake::Task["dummy:do_something_once"].reenable
    DummyOutput.count = 0
  end

  test "calls the rake task (increases counter by one)" do
    2.times do
      Rake::Task["dummy:do_something_once"].invoke
      assert_equal 1, DummyOutput.count
    end
  end
end
