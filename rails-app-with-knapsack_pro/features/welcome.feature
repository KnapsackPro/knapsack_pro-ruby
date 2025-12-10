Feature: Go to calculator from welcome page

  Scenario: Visit calculator
    Given I visit welcome page
    When I click on calculator link
    Then I should be on calculator page
