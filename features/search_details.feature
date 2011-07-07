Feature: retrieve object's details

	So that a web site can get a specific object's details
	As a federated website, or any other anonymous visitor
	I want to make a search request for a specific object when I
	know the URI and retrieve all the details available about that object.

	Scenario: Get an object by URI
		Given I am not authenticated
		When I details with <uri=http://asp6new.alexanderstreet.com/romr/1000889336> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml number of hits is "1"
		And the xml xpath "search/results/result/uri" is "http://asp6new.alexanderstreet.com/romr/1000889336"
		And the xml xpath "search/results/result/archive" is "romr"
		And the xml xpath "search/results/result/role_aut/value" is "Prince, John Critchley, 1808-1866"

	Scenario: Pass in a bad URI
		Given I am not authenticated
		When I details with <uri=not a uri> using xml
		Then the response status should be "400"
		And the xml xpath "error/message" is "Bad parameter (uri): not a uri. Must match: (?-mix:^([A-Za-z0-9+.-]+):\/\/.+$)"

	Scenario: Object not found
		Given I am not authenticated
		When I details with <uri=http://XXXXXXXX> using xml
		Then the response status should be "404"

	Scenario: Display an object's details
		Given I am not authenticated
		When I details with <uri=http://asp6new.alexanderstreet.com/romr/1000889336>
		Then the response status should be "200"
		And I should see "Nineteenth-Century English Labouring–Class Poets, Vol. 2: 1830-1860"

	Scenario: URI contains a space
		Given I am not authenticated
		When I details with <uri=http://www.amdigital.co.uk/UL MM6> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml number of hits is "1"
		And the xml xpath "search/results/result/uri" is "http://www.amdigital.co.uk/UL MM6"
