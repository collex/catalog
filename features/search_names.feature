Feature: Search for names

	So that a web site can provide a list of authors, editors, and publishers to the end user
	As a federated web site or an anonymous visitor
	I want to access a list of all names that match my search request

	Scenario: Do a simple name retrieval
		Given I am not authenticated
		When I names with <q=+tree&y=+1844> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/names_results.xsd"
		And the xml "author" list is "elliot,100,whitman,5,poe,34"
		And the xml "editor" list is "elliot,100,whitman,5,poe,34"
		And the xml "publisher" list is "elliot,100,whitman,5,poe,34"

	Scenario: Do a large name retrieval
		Given I am not authenticated
		When I names with <q=+tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/names_results.xsd"
		And the xml "author" list is "elliot,100,whitman,5,poe,34"
		And the xml "editor" list is "elliot,100,whitman,5,poe,34"
		And the xml "publisher" list is "elliot,100,whitman,5,poe,34"
