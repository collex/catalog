Feature: Routing

	So that unauthorized users can't access unexpected page
	As any user
	There can't be any access to any routes except the expected ones
	The routes that would normally be generated but aren't needed should throw an error

	Scenario: Search controller
		Then only the routes "index,show" should exist in "search"

	Scenario: Archives controller
		Given I am not authenticated
		Then all routes should exist in "archives"
		Then all routes in "archives" should redirect to "home"
		Given I am logged in
		When I restfully index a "archives"
		Then I should be on the "archives" page

	Scenario: Federations controller
		Given I am not authenticated
		Then all routes should exist in "federations"
		Then all routes in "federations" should redirect to "home"
		Given I am logged in
		When I restfully index a "federations"
		Then I should be on the "federations" page

	Scenario: Genres controller
		Given I am not authenticated
		Then all routes should exist in "genres"
		Then all routes in "genres" should redirect to "home"
		Given I am logged in
		When I restfully index a "genres"
		Then I should be on the "genres" page

#TODO: these should exist only for an authorized federation
	Scenario: Exhibits controller
		Then all routes should exist in "exhibits"

	Scenario: Locals controller
		Then all routes should exist in "locals"
