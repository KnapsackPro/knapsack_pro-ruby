Feature: Foo
  Background:
    Given I have a two

  Scenario: Add one (1st)
    When I add one
    Then I expect a three

  Scenario: Add one (2nd)
    When I add one
    Then I expect a three
