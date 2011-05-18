Feature: Routing

	So that unauthorized users can't access unexpected pages
	As any user
	There can't be any access to any routes except the expected ones.
	The routes that would normally be generated but aren't needed should throw an error.
	So, without authentication, the visitor can see only the index path, but no other
	route. When logged in, the visitor can see all the standard restful routes.
	If not logged in, then the index page that is returned doesn't not have the "new", "edit", or "delete" links on it.

	Scenario: Search controller
		Then only the routes "index,show" should exist in "search"

	Scenario: Archives controller
		Given I am not authenticated
		And the standard archives
		Then all routes should exist in "archives"
		Then all routes in "archives" except "index" should redirect to "home"
		When I go to "archives"
		Then I should be on the "archives" page
		And I should not see "new"
		And I should not see "edit"
		And I should not see "delete"
		When I go to "archives" using xml
		Then I should be on the "archives" page
		When I restfully show "1" from "archives"
		Then I should be on the home page
		Given I am logged in
		When I restfully show "1" from "archives"
		Then I should be on the "archives" page

	Scenario: Federations controller
		Given I am not authenticated
		And the standard federations
		Then all routes should exist in "federations"
		Then all routes in "federations" except "index" should redirect to "home"
		When I go to "federations"
		Then I should be on the "federations" page
		And I should not see "new"
		And I should not see "edit"
		And I should not see "delete"
		When I go to "federations" using xml
		Then I should be on the "federations" page
		When I restfully show "1" from "federations"
		Then I should be on the home page
		Given I am logged in
		When I restfully show "1" from "federations"
		Then I should be on the "federations" page

	Scenario: Genres controller
		Given I am not authenticated
		And the standard genres
		Then all routes should exist in "genres"
		Then all routes in "genres" except "index" should redirect to "home"
		When I go to "genres"
		Then I should be on the "genres" page
		And I should not see "new"
		And I should not see "edit"
		And I should not see "delete"
		When I go to "genres" using xml
		Then I should be on the "genres" page
		When I restfully show "1" from "genres"
		Then I should be on the home page
		Given I am logged in
		When I restfully show "1" from "genres"
		Then I should be on the "genres" page

#TODO: these should exist only for an authorized federation
	Scenario: Exhibits controller
		Then all routes should exist in "exhibits"

	Scenario: Locals controller
		Then all routes should exist in "locals"
