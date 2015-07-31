Feature: Workbench

  Background:
    Given pages:
      | title        | url                          |
      | Datasets     | dataset                      |
      | Needs Review | admin/workbench/needs-review |
      | My drafts    | admin/workbench/drafts       |
    Given users:
      | name    | mail             | roles                |
      | Jeff    | jeff@test.com    | portal administrator |
      | Gabriel | gabriel@test.com | content editor       |
      | Katie   | katie@test.com   | data contributor     |
      | Celeste | celeste@test.com | data contributor     |
      | Jaz     | jaz@test.com     | data contributor     |
    And "tags" terms:
      | name   |
      | Health |
      | Gov    |
    And datasets:
      | title      | author  | moderation   | date         | tags   |
      | Dataset 01 | Katie   | draft        | Feb 01, 2015 | Health |
      | Dataset 02 | Gabriel | published    | Mar 13, 2015 | Gov    |
      | Dataset 03 | Katie   | published    | Feb 17, 2013 | Health |
      | Dataset 04 | Celeste | draft        | Jun 21, 2015 | Gov    |
      | Dataset 05 | Katie   | needs_review | Jun 21, 2015 | Gov    |
    And "Format" terms:
      | name  |
      | csv   |
    And resources:
      | title        | author  | dataset    | moderation | format |
      | Resource 041 | Celeste | Dataset 04 | published  | csv    |
      | Resource 042 | Celeste | Dataset 04 | published  | csv    |
      | Resource 051 | Katie   | Dataset 05 | published  | csv    |

  @api
  Scenario: As a Data Contributor I want to moderate my own Datasets
    Given I am logged in as "Katie"
    And I am on "Dataset 01" page
    When I follow "Moderate"
    Then I should see "Needs Review" in the "#edit-state" element
    And I should not see "Published" in the "#edit-state" element
    And I press "Apply"
    And I should see "Draft --> Needs Review"

  @api
  Scenario: As a Content Editor I want to Publish datasets posted by a Data Contributor
    Given I am logged in as "Gabriel"
    And I am on "Dataset 01" page
    When I follow "Moderate"
    Then I should see "Needs Review" in the "#edit-state" element
    When I press "Apply"
    Then I should see "Draft --> Needs Review"
    And I should see "Published" in the "#edit-state" element
    When I press "Apply"
    Then I should see "Needs Review --> Published"
    Given I am an anonymous user
    And I am on "Dataset 01" page
    Given I should not see the error message "Access denied. You must log in to view this page."

  @api
  Scenario: As a Portal Administrator I want to moderate all content
    Given I am logged in as "Jeff"
    And I am on "Dataset 01" page
    When I follow "Moderate"
    Then I should see "Needs Review" in the "#edit-state" element
    And I should see "Published" in the "#edit-state" element
    When I follow "Edit draft"
    And I fill in "Description" with "Dataset 01 edited"
    And I press "Finish"
    Then I should see "Dataset Dataset 01 has been updated"
    Given I am an anonymous user
    And I am on "Dataset 01" page
    Given I should not see the error message "Access denied. You must log in to view this page."

  @api
  Scenario Outline: View 'My workbench' page
    Given I am logged in as a user with the "<role name>" role
    Then I should see the link "My Workbench" in the navigation region
    When I follow "My Workbench"
    Then I should see "My Content"
    And I should see "Create content"
    And I should see "My drafts"
    And I should see "Needs review"

  Examples:
    | role name                 |
    | portal administrator      |
    | content editor            |

  @api
  Scenario: View 'My workbench' page for "data contributor" role
    Given I am logged in as a user with the "data contributor" role
    Then I should see the link "My Workbench" in the navigation region
    When I follow "My Workbench"
    Then I should see "My Content"
    And I should see "Create content"
    And I should see "My drafts"
    And I should see "Needs review"

  @api
  Scenario: View 'Stale drafts' menu item for "portal administrator" role
    Given I am logged in as a user with the "portal administrator" role
    Then I should see the link "My Workbench" in the navigation region
    When I follow "My Workbench"
    Then I should see "Stale drafts"

  @api
  Scenario: View 'Stale reviews' menu item for "portal administrator" role
    Given I am logged in as a user with the "portal administrator" role
    Then I should see the link "My Workbench" in the navigation region
    When I follow "My Workbench"
    Then I should see "Stale reviews"


##################################################################
# EMAIL NOTIFICATION
##################################################################

  @api @mail
  Scenario: As a Content Editor I want to receive an email notification when "Data Contributor" add a Dataset that "Needs Review".
    Given I am logged in as "Katie"
    And I am on "Datasets" page
    When I click "Add Dataset"
    And I fill in the following:
      | Title                     | Dataset That Needs Review |
      | Description               | Test Behat Dataset 06     |
      | autocomplete-deluxe-input | Health                    |
    And I press "Next: Add data"
    And I fill in the following:
      | Title                     | Resource 061            |
      | Description               | Test Behat Resource 061 |
      | autocomplete-deluxe-input | CSV                     |
    And I press "Save"
    Then I should see the success message "Resource Resource 061 has been created."
    And I click "Back to dataset"
    Then I follow "Moderate"
    Then I should see "Needs Review" in the "#edit-state" element
    And I should not see "Published" in the "#edit-state" element
    And I press "Apply"
    And I should see "Draft --> Needs Review"
    And user Gabriel should receive an email containing "Please review the recent update at"

  @api @javascript @mail
  Scenario: Request dataset review (Change dataset status from 'Draft' to 'Needs review')
    Given I am logged in as "Celeste"
    And I follow "My Workbench"
    And I follow "My drafts"
    Then I should see "Dataset 04"
    When I expand the "Dataset 04" accordion
    Then I should see "Current Moderation state: Draft"
    When I click "Change to Needs Review"
  #  Then I should not see "Dataset 04"
    And the moderation state of node "Dataset 04" of type "Dataset" should be "Needs review"

  @api @javascript @mail
  Scenario: As Content Editor Review Dataset (Change dataset status from 'Needs review' to 'Draft')
    Given I am logged in as "Gabriel"
    And I follow "My Workbench"
    And I follow "Needs review"
    And I should see "Dataset 05"
    When I expand the "Dataset 05" accordion
    Then I should see "Current Moderation state: Needs Review"
    When I click "Change to Draft"
    Then I should not see "Dataset 05"
    And the moderation state of node "Dataset 05" of type "Dataset" should be "Draft"
