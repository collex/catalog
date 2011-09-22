Feature: Normal search

	So that a web site can provide a search capability for any object in solr
	As a federated website, or any other anonymous visitor
	I want to make a search request and receive results from the standard solr index

	Scenario: Do a simple solr search
		Given I am not authenticated
		When I search with <q=+tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "33"
		And the xml "genre" facet "Book History" is "34"

	Scenario: Browse to a simple solr search
		Given I am not authenticated
		When I search with <q=+tree>
		Then the response status should be "200"
		And I should see in this order "Search Results, Total found: 23,979, Results, Facets, genre, has_full_text"

	Scenario: Do a solr search with utf-8
		Given I am not authenticated
		When I search with <q=+Brontë> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "1996"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "18"
		And the xml "genre" facet "Book History" is "-1"
		And the xml "genre" facet "Fiction" is "18"

	Scenario: Do a solr search with apostrophe
		Given I am not authenticated
		When I search with <q=+don't> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "40894"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "archive" facets is "91"
		And the xml "genre" facet "Poetry" is "409"

	Scenario: Do a solr search with quotes
		Given I am not authenticated
		When I search with <q=+"never more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "3414"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "federation" facets is "2"
		And the xml "has_full_text" facet "true" is "3398"

	Scenario: Do a solr search with mismatched quotes
		Given I am not authenticated
		When I search with <q=+"never more> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "3414"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "32"
		And the xml "genre" facet "Book History" is "5"

	Scenario: Do a solr search with multiple terms
		#TODO-PER: Figure out the correct response for all these permutations
		Given I am not authenticated
		When I search with <q=+never+more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "3414"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "32"
		And the xml "genre" facet "Book History" is "5"
		When I search with <q=-never+more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "1403112"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "35"
		And the xml "genre" facet "Book History" is "22867"
		When I search with <q=+never-more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "3414"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "32"
		And the xml "genre" facet "Book History" is "5"
		When I search with <q=-never-more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "1403112"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "35"
		And the xml "genre" facet "Book History" is "22867"
		When I search with <q=+more+never"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "175"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "22"
		And the xml "genre" facet "Book History" is "1"
		When I search with <q=-more+never"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "1406351"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "35"
		And the xml "genre" facet "Book History" is "22871"
		When I search with <q=+more-never"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "175"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "22"
		And the xml "genre" facet "Book History" is "1"
		When I search with <q=-more-never"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "1406351"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "35"
		And the xml "genre" facet "Book History" is "22871"

	Scenario: Do a solr search by archive
		Given I am not authenticated
		When I search with <a=+rossetti> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "24552"
		And the xml number of hits is "30"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "17"
		And the xml "genre" facet "Manuscript" is "409"
		And the xml number of "archive" facets is "105"

	Scenario: Do a solr search by genre
		Given I am not authenticated
		When I search with <g=+Poetry> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "69505"
		And the xml number of "genre" facets is "30"
		And the xml "genre" facet "Book History" is "659"
		When I search with <g=+Criticism+Manuscript> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "54"

	Scenario: Do a solr search by federation
		Given I am not authenticated
		When I search with <f=+18thConnect> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "673462"
		And the xml number of "freeculture" facets is "2"
		And the xml "freeculture" facet "true" is "85387"
		And the xml "freeculture" facet "false" is "588075"

	Scenario: Do a solr search with all parameters (and be sure that the sorting rearranges the results)
		Given I am not authenticated
		When I search with <q=+tree&t=-tree&aut=+John&ed=-quincy&pub=-york&y=-1850&a=-rossetti&g=+Poetry&f=+NINES&o=+fulltext&sort=author desc&start=1&max=5&hl=on> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "54"
		And the xml number of hits is "5"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "3"
		And the xml hit "0" is "http://alex_st/1000148885"
		When I search with <q=+tree&t=-tree&aut=+John&ed=-quincy&pub=-york&y=-1850&a=-rossetti&g=+Poetry&f=+NINES&o=+fulltext&sort=title asc&start=1&max=5&hl=on> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "54"
		And the xml hit "0" is "http://asp6new.alexanderstreet.com/romr/1000889336"

	Scenario: Do a solr search with special terms and common words
		Given I am not authenticated
		When I search with <q=+to+be+or+not+to+be> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "218"
		When I search with <q=+"to be or not to be"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "218"
		When I search with <q=+rank+and+file> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "895"

		Scenario: Do a wildcard search
			Given I am not authenticated
			When I search with <q=+bront*> using xml
			Then the response status should be "200"
			And the xml has the structure "xsd/search_results.xsd"
			And the xml search total is "1996"
			And the xml number of hits is "30"
			When I search with <q=+Bront*> using xml
			Then the response status should be "200"
			And the xml has the structure "xsd/search_results.xsd"
			And the xml search total is "1996"
			And the xml number of hits is "30"
