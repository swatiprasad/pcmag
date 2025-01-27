Feature: An editor organizes submissions onto pages of a magazine
	A magazine has been published!
	As an editor,
	I want to arrange it the same way on the web as it is when printed
	because _flow matters_.

	Background: We've published a magazine
		Given I am signed in as an editor named "Swati Prasad"
		And there is a submission called "Everyone Dies, Anyway"
		And a magazine titled "Fruit Blots" has been published
		And I am on the "Fruit Blots" magazine page

	Scenario: I see that the vanilla published magazine has sensible defaults
		Then I should see "Cover Notes Staff ToC 1" for the page numbers
		And I should see "Fruit Blots"
		And I should see "Cover Art"

	Scenario: I can add pages to the magazine
		When I press "+"
		Then I should see "Cover Notes Staff ToC 1 2" for the page numbers

  Scenario: I can remove a page from the magazine
    When I press "x"
    Then I should see "Notes Staff ToC 0" for the page numbers

  @pending
  @javascript
  Scenario: I can rename pages
    When I follow "1"
    And I click on "1"
    And I type "Last" and hit Return
    And I refresh the page
    Then I should see "Last"

	@pending
	@javascript
	Scenario: I can drag submissions onto other pages
    When I follow "1"
    And I press "+"
		And I drag "Everyone Dies, Anyway" to "2"
		Then I should be on page 1
		And I should not see "Everyone Dies, Anyway"
