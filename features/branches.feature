Feature: Branches
I should be able to list and add new branches to the system

Background:
  Given I have some branches

Scenario: Listing branches
  When  I visit the branches index page
  Then  I should see all branches listed

Scenario: Adding a new branch
  When  I create a new branch 
  Then  I should see the new branch in the branches list

Scenario: Deleting a branch
  When  I delete a branch
  Then  I should not see the deleted branch in the branches list

Scenario: Renaming a branch
  When  I rename a branch
  Then  I should see the new branch name in the branches list 
  And   I should not see the old branch name in the branches list

Scenario: Listing branch pages
  When  I visit a branch details page 
  Then  I should see a list of its pages