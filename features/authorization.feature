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

