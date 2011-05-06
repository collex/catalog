Feature: Authorization

	So that unauthorized users can't access the administration pages
	As an anonymous user
	There can't be any access to any of the administration pages
	However, there should be access when the user is logged in

	Scenario: Not logged in - Genres
		Given I am not authenticated
		When I go to the genres page
		Then I should be on the home page

	Scenario: Not logged in - Archives
		Given I am not authenticated
		When I go to the archives page
		Then I should be on the home page

	Scenario: Not logged in - Federations
		Given I am not authenticated
		When I go to the federations page
		Then I should be on the home page

	Scenario: Logged in - Genres
		Given I am logged in
		When I go to the genres page
		Then I should be on the genres page

	Scenario: Logged in - Archives
		Given I am logged in
		When I go to the archives page
		Then I should be on the archives page

	Scenario: Logged in - Federations
		Given I am logged in
		When I go to the federations page
		Then I should be on the federations page

	Scenario: Not logged in - Search
		Given I am not authenticated
		When I go to the search page
		Then I should be on the search page

	Scenario: Not logged in - Local
		Given I am not authenticated
		When I go to the locals page
		Then I should be on the locals page

	Scenario: Not logged in - Exhibit
		Given I am not authenticated
		When I go to the exhibits page
		Then I should be on the exhibits page

	Scenario: Not logged in - Home
		Given I am not authenticated
		When I go to the home page
		Then I should be on the home page
