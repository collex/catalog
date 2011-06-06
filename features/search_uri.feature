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
		And test all the details