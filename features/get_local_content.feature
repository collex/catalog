Feature: Search Local Content

	So that a web site can use this service for its own content, instead of having to set up solr,
	As a federated web site
	I want to make a search request for information that I've previously indexed.

	Scenario: Simple search returning all results
		Given the standard federations
		When I search local content with <federation=NINES> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "221"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=Exhibit_4&last_modified=2010-03-16T20:23:04Z&object_id=4&object_type=Exhibit&title=Representing the Renaissance (Annotated Bibliography)"

	Scenario: Bad credentials
		Given the standard federations
		When a hacker searches local content with <federation=NINES> using xml
		Then the response status should be "401"

	Scenario: Simple search for all community
		Given the standard federations
		When I search local content with <federation=NINES&section=community> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

	Scenario: Simple search for all classroom
		Given the standard federations
		When I search local content with <federation=NINES&section=classroom> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

	Scenario: Simple search for all community objects
		Given the standard federations
		When I search local content with <federation=NINES&section=community&object_type=group> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

		When I search local content with <federation=NINES&section=community&object_type=exhibit> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

		When I search local content with <federation=NINES&section=community&object_type=cluster> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

		When I search local content with <federation=NINES&section=community&object_type=discussion> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

	Scenario: Simple search for community objects as a logged in user
		Given the standard federations
		When I search local content with <federation=NINES&section=community&member=6,8&admin=1> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

	Scenario: Query search for community objects
		Given the standard federations
		When I search local content with <federation=NINES&section=community&q=+rossetti> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/search_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" has the text "abcde <em>rossetti</em> fghi"

	Scenario: Simple sorted search for community objects
		Given the standard federations
		When I search local content with <federation=NINES&section=community&sort=title asc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

		When I search local content with <federation=NINES&section=community&sort=title desc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

		When I search local content with <federation=NINES&section=community&sort=last_modified asc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

		When I search local content with <federation=NINES&section=community&sort=last_modified desc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

	Scenario: Simple paginated search for classroom objects
		Given the standard federations
		When I search local content with <federation=NINES&section=classroom&sort=title asc&start=5&max=5> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

		When I search local content with <federation=NINES&section=classroom&sort=title asc&start=10&max=5> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"

		When I search local content with <federation=NINES&section=classroom&sort=title asc&start=5000&max=5> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "23979"
		And the xml number of hits is "10"
		And the xml hit "0" contains "<key>Exhibit_4</key><date_modified>xx</date_modified>"
