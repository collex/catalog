Feature: Authorization

	So that unauthorized users can't access the administration pages
	As an anonymous user
	There can't be any access to any of the administration pages
	However, there should be access when the user is logged in

	Scenario: Not logged in - Genres
		Given I am not authenticated
		When I go to the genres page
		Then I should be on the genres page
		And I should not see "New"
		When I go to the new genre page
		Then I should be on the home page
		And I should see "Please log in to access that page."

	Scenario: Not logged in - Archives
		Given I am not authenticated
		When I go to the archives page
		Then I should be on the archives page
		And I should not see "New"
		When I go to the new archive page
		Then I should be on the home page
		And I should see "Please log in to access that page."

	Scenario: Not logged in - Federations
		Given I am not authenticated
		When I go to the federations page
		Then I should be on the federations page
		And I should not see "New"
		When I go to the new federation page
		Then I should be on the home page
		And I should see "Please log in to access that page."

	Scenario: Logged in - Genres
		Given I am logged in
		When I go to the genres page
		Then I should be on the genres page
		And I should see "New"

	Scenario: Logged in - Archives
		Given I am logged in
		When I go to the archives page
		Then I should be on the archives page
		And I should see "New"

	Scenario: Logged in - Federations
		Given I am logged in
		When I go to the federations page
		Then I should be on the federations page
		And I should see "New"

	Scenario: Not logged in - Search
		Given I am not authenticated
		When I go to the search page
		Then I should be on the search page

	Scenario: Not logged in - Local
		Given I am not authenticated
		When I go to the locals page
		Then I should be on the locals page
		And I should see "You do not have permission to do this."

	Scenario: Not logged in - Home
		Given I am not authenticated
		When I go to the home page
		Then I should be on the home page
