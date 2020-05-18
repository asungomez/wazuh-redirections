Feature: Branches
I should be able to retrieve a branch's pages and edit its relationships

Background:
  Given I have some branches

Scenario: Retrieving pages
  When  I refresh a branch 
  Then  I should see an updated list of its pages

Scenario: Listing branch new pages
  Given A branch has some new pages 
  When  I list the branch's new pages 
  Then  I should see all of the branch's new pages

Scenario: Listing branch deleted pages
  Given A branch has some deleted pages 
  When  I list the branch's deleted pages 
  Then  I should see all of the branch's deleted pages

Scenario: Listing branch merged pages
  Given A branch has some merged pages 
  When  I list the branch's merged pages 
  Then  I should see all of the branch's merged pages

Scenario: Listing branch split pages
  Given A branch has some split pages 
  When  I list the branch's split pages 
  Then  I should see all of the branch's split pages

Scenario: Listing branch renamed pages
  Given A branch has some renamed pages 
  When  I list the branch's renamed pages 
  Then  I should see all of the branch's renamed pages

Scenario: Marking a page as renamed
  Given The branch has a new page 
  And   The branch has a deleted page 
  When  I mark the new page as renamed 
  Then  I should see the page in the renamed pages list 
  And   I should not see the new page in the new pages list
  And   I should not see the older page in the deleted pages list


Scenario: Marking a page as merged
  Given The branch has a new page 
  And   The branch has several deleted pages 
  When  I mark the new page as a merge of the deleted pages 
  Then  I should see the page in the merged pages list 
  And   I should not see the new page in the new pages list 
  And   I should not see the older pages in the deleted pages list

Scenario: Marking some pages as split
  Given The branch has some new pages 
  And   The branch has a deleted page 
  When  I mark the new pages as a split of the deleted page 
  Then  I should see the pages in the split pages list 
  And   I should not see the new pages in the new pages list 
  And   I should not see the older page in the deleted pages list 

Scenario: Marking a page as new
  Given The branch has a renamed page 
  When  I mark the renamed page as new 
  Then  I should see the renamed page in the new pages list 
  And   I should not see the new page in the renamed pages list 
  And   I should see the old page in the deleted pages list 
  And   I should not see the old page in the renamed pages list

