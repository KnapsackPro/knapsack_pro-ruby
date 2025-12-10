Feature: Scenario outline tests for calculator

  Scenario Outline: Adding scenario outline
    Given I visit calculator
    When there are <x> cucumbers
    And I add <y> cucumbers
    Then I should have <result> cucumbers

    Examples:
      | x   | y    | result |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |
      | 2   | 3    | 5      |
      | 5   | 3    | 8      |
      | 123 | 5342 | 5465   |

  Scenario: Adding
    Given I visit calculator
    When there are 2 cucumbers
    And I add 10 cucumbers
    Then I should have 12 cucumbers
