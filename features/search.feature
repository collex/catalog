Feature: Normal search

	So that a web site can provide a search capability for any object in solr
	As a federated website, or any other anonymous visitor
	I want to make a search request and receive results from the standard solr index

	Scenario: Do a simple solr search
		Given I am not authenticated
		When I search with <q=+tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"

	Scenario: Browse to a simple solr search
		Given I am not authenticated
		When I search with <q=+tree>
		Then the response status should be "200"
		And I should see in this order "Search Results, Total found: 2924, Results, Facets, genre, has_full_text"

	Scenario: Do a solr search with utf-8
		Given I am not authenticated
		When I search with <q=+Brontë> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"

	Scenario: Do a solr search with apostrophe
		Given I am not authenticated
		When I search with <q=+don't> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "1767"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "archive" facets is "11"
		And the xml "genre" facet "Poetry" is "120"

	Scenario: Do a solr search with quotes
		Given I am not authenticated
		When I search with <q=+"never more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "794"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "federation" facets is "2"
		And the xml "has_full_text" facet "true" is "782"

	Scenario: Do a solr search with mismatched quotes
		Given I am not authenticated
		When I search with <q=+"never more> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"

	Scenario: Do a solr search with multiple terms
		#TODO-PER: Figure out the correct response for all these permutations
		Given I am not authenticated
		When I search with <q=+never+more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"
		When I search with <q=-never+more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"
		When I search with <q=+never-more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"
		When I search with <q=-never-more"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"
		When I search with <q=+more+never"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"
		When I search with <q=-more+never"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"
		When I search with <q=+more-never"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"
		When I search with <q=-more-never"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "2924"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "31"
		And the xml "genre" facet "Book History" is "34"

	Scenario: Do a solr search by archive
		Given I am not authenticated
		When I search with <a=+rossetti> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "24552"
		And the xml number of hits is "10"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "17"
		And the xml "genre" facet "Manuscript" is "409"

	Scenario: Do a solr search by genre
		Given I am not authenticated
		When I search with <g=+Poetry> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "49857"
		And the xml number of "genre" facets is "28"
		And the xml "genre" facet "Book History" is "593"

	Scenario: Do a solr search by federation
		Given I am not authenticated
		When I search with <f=+18thConnect> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "586911"
		And the xml number of "freeculture" facets is "2"
		And the xml "freeculture" facet "true" is "725"
		And the xml "freeculture" facet "false" is "586186"

	Scenario: Do a solr search with all parameters (and be sure that the sorting rearranges the results)
		Given I am not authenticated
		When I search with <q=+tree&t=-tree&aut=+John&ed=-quincy&pub=-york&y=-1850&a=-rossetti&g=+Poetry&f=+NINES&o=+fulltext&sort=author desc&start=1&max=5&hl=on> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "288952"
		And the xml number of hits is "5"
		And the xml number of facets is "6"
		And the xml number of "genre" facets is "32"
		And the xml hit "0" is "lib://lilly/1145627"
		When I search with <q=+tree&t=-tree&aut=+John&ed=-quincy&pub=-york&y=-1850&a=-rossetti&g=+Poetry&f=+NINES&o=+fulltext&sort=title asc&start=1&max=5&hl=on> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "288952"
		And the xml hit "0" is "http://www.rossettiarchive.org/docs/2p-1863.1880.v2.rad#0.5.30.3"

	Scenario: Do a solr search with special terms and common words
		Given I am not authenticated
		When I search with <q=+to+be+or+not+to+be> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "288952"
		When I search with <q=+"to be or not to be"> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "288952"
		When I search with <q=+rank+and+file> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "288952"
