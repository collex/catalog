Feature: Routing

	So that unauthorized users can't access unexpected pages
	As any user
	There can't be any access to any routes except the expected ones.
	The routes that would normally be generated but aren't needed should throw an error.
	So, without authentication, the visitor can see only the index path, but no other
	route. When logged in, the visitor can see all the standard restful routes.
	If not logged in, then the index page that is returned doesn't not have the "new", "edit", or "delete" links on it.

	Scenario: Search controller
		Then only the routes "index" should exist in "search"

	Scenario: Archives controller
		Given I am not authenticated
		And the standard archives
		Then all routes should exist in "archives"
		Then all routes in "archives" except "index" should redirect to "the home page"
		When I go to the archives page
		Then I should be on the archives page
		And I should not see "New Archive"
		And I should not see "edit"
		And I should not see "delete"
		When I go to the archives page using xml
		Then I should be on the archives page using xml
		When I restfully show "1" from "archives"
		Then I should be on the home page
		And I should see "Please log in to access that page."
		Given I am logged in
		When I restfully show "1" from "archives"
		Then I should be on the show archives 1 page

	Scenario: Federations controller
		Given I am not authenticated
		And the standard federations
		Then all routes should exist in "federations"
		Then all routes in "federations" except "index" should redirect to "the home page"
		When I go to the federations page
		Then I should be on the federations page
		And I should not see "new"
		And I should not see "edit"
		And I should not see "delete"
		When I go to the federations page using xml
		Then I should be on the federations page using xml
		When I restfully show "1" from "federations"
		Then I should be on the home page
		And I should see "Please log in to access that page."
		Given I am logged in
		When I restfully show "1" from "federations"
		Then I should be on the show federations 1 page

	Scenario: Genres controller
		Given I am not authenticated
		And the standard genres
		Then all routes should exist in "genres"
		Then all routes in "genres" except "index" should redirect to "the home page"
		When I go to the genres page
		Then I should be on the genres page
		And I should not see "new"
		And I should not see "edit"
		And I should not see "delete"
		When I go to the genres page using xml
		Then I should be on the genres page using xml
		When I restfully show "1" from "genres"
		Then I should be on the home page
		And I should see "Please log in to access that page."
		Given I am logged in
		When I restfully show "1" from "genres"
		Then I should be on the show genres 1 page

	Scenario: Exhibits controller
		Then only the routes "create,delete" should exist in "exhibits"

	Scenario: Locals controller
		Then only the routes "index,create,update,delete" should exist in "locals"
