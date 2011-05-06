Feature: Routing

	So that unauthorized users can't access unexpected page
	As any user
	There can't be any access to any routes except the expected ones
	The routes that would normally be generated but aren't needed should throw an error

	Scenario: Search controller
		Then only the routes "index,show" should exist in "search"

#TODO: these should exist only for a logged in user
	Scenario: Archives controller
		Then all routes should exist in "archives"

	Scenario: Federations controller
		Then all routes should exist in "federations"

	Scenario: Genres controller
		Then all routes should exist in "genres"

#TODO: these should exist only for an authorized federation
	Scenario: Exhibits controller
		Then all routes should exist in "exhibits"

	Scenario: Locals controller
		Then all routes should exist in "locals"
