Feature: Dir with spaces

  @Test
  Scenario: Adding
    Given I visit calculator
    When there are 3 cucumbers
    And I add 5 cucumbers
    Then I should have 8 cucumbers
