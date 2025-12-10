Feature: Test a rake task

Scenario: Test dummy:do_something_once
  Given I rake_require "tasks/dummy"
  When I invoke the "dummy:do_something_once" task
  Then the count on "DummyOutput" equals 1
  Given I reenable the "dummy:do_something_once" task
  And I reset the count on "DummyOutput" to 0
  And I rake_require "tasks/dummy"
  When I invoke the "dummy:do_something_once" task
  Then the count on "DummyOutput" equals 1

Scenario: Test another_dummy:do_something_once
  Given I load_rakefile "tasks/another_dummy.rake"
  When I invoke the "another_dummy:do_something_once" task
  Then the count on "AnotherDummyOutput" equals 1
  Given I reenable the "another_dummy:do_something_once" task
  And I reset the count on "AnotherDummyOutput" to 0
  When I invoke the "another_dummy:do_something_once" task
  Then the count on "AnotherDummyOutput" equals 1
