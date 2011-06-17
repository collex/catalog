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
		And the xml search total is "67"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=Exhibit_4&last_modified=2010-03-16T20:23:04Z&object_id=4&object_type=Exhibit&title=Representing the Renaissance (Annotated Bibliography)"

	Scenario: Simple search for all classroom
		Given the standard federations
		When I search local content with <federation=NINES&section=classroom> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "144"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=Exhibit_49&last_modified=2010-03-05T22:19:06Z&object_type=Exhibit&object_id=49&title=Broxterman ENGL 227 Project"
		When I search local content with <federation=NINES&section=classroom&group=2> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "122"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=Exhibit_49&last_modified=2010-03-05T22:19:06Z&object_type=Exhibit&object_id=49&title=Broxterman ENGL 227 Project"

	Scenario: Simple search for all community objects
		Given the standard federations
		When I search local content with <federation=NINES&section=community&object_type=Group> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "15"
		And the xml number of hits is "15"
		And the xml hit "0" contains "key=Group_1&last_modified=2011-03-30T18:59:02Z&object_type=Group&object_id=1&title=Victorians Institute Journal"

		When I search local content with <federation=NINES&section=community&object_type=Exhibit> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "18"
		And the xml number of hits is "18"
		And the xml hit "0" contains "key=Exhibit_4&last_modified=2010-03-16T20:23:04Z&object_type=Exhibit&object_id=4&title=Representing the Renaissance (Annotated Bibliography)"

		When I search local content with <federation=NINES&section=community&object_type=Cluster> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "0"

		When I search local content with <federation=NINES&section=community&object_type=Cluster&admin=25> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "1"
		And the xml number of hits is "1"
		And the xml hit "0" contains "key=Cluster_4&last_modified=2011-01-27T22:01:54Z&object_type=Cluster&object_id=4&title=Fightin' words"

		When I search local content with <federation=NINES&section=community&object_type=DiscussionThread> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "34"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=DiscussionThread_2&last_modified=2010-12-20T16:40:05Z&object_type=DiscussionThread&object_id=2&title=Discussions in NINES"

	Scenario: Simple search for classroom objects as a logged in user
		Given the standard federations
		When I search local content with <federation=NINES&section=classroom&member=6&admin=13,19> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "173"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=Exhibit_353&last_modified=2010-11-22T00:25:21Z&object_type=Exhibit&object_id=353&title=Prostitutes' Place in Society"

	Scenario: Query search for community objects
		Given the standard federations
		When I search local content with <federation=NINES&section=community&q=+rossetti> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "10"
		And the xml number of hits is "10"
		And the xml hit "0" has the text "The Life \n \n \n \n Dante Gabriel <em>Rossetti</em> was born in London on 12 May 1828 and he died on Easter Day, 9 April 1882. He spent nearly his entire working life in the city of his birth, and indeed he only left Great Britain three times, in each case but the first quite briefly. Though his work is steeped in Italian traditions (both poetical and pictorial), <em>Rossetti</em> never visited Italy. He is first and always an English - more, a London - writer and artist. \n   His father was the celebrated (and controversial) Dante scholar and Italian political exile Gabriele <em>Rossetti</em> (1783-1854). His mother"

	Scenario: Simple sorted search for community objects
		Given the standard federations
		When I search local content with <federation=NINES&section=community&sort=title asc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "67"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=DiscussionThread_33&last_modified=2010-12-19T20:35:51Z&object_type=DiscussionThread&object_id=33&title=Alexa Wilding Sale date is wrong"

		When I search local content with <federation=NINES&section=community&sort=title desc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "67"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=Group_21&last_modified=2010-12-09T19:58:50Z&object_type=Group&object_id=21&title=William Turner's influence on Claude Monet "

		When I search local content with <federation=NINES&section=community&sort=last_modified asc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "67"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=Exhibit_136&last_modified=2009-08-25T14:04:58Z&object_type=Exhibit&object_id=136&title=Brown ENGL 227"

		When I search local content with <federation=NINES&section=community&sort=last_modified desc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "67"
		And the xml number of hits is "30"
		And the xml hit "0" contains "key=DiscussionThread_49&last_modified=2011-04-15T20:22:48Z&object_type=DiscussionThread&object_id=49&title=Does the discussion step faster?"

	Scenario: Simple paginated search for classroom objects
		Given the standard federations
		When I search local content with <federation=NINES&section=classroom&sort=title asc&start=5&max=5> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "144"
		And the xml number of hits is "5"
		And the xml hit "0" contains "key=Exhibit_198&last_modified=2009-12-09T05:10:33Z&object_type=Exhibit&object_id=198&title=APatton227F09 "

		When I search local content with <federation=NINES&section=classroom&sort=title asc&start=10&max=5> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "144"
		And the xml number of hits is "5"
		And the xml hit "0" contains "key=Exhibit_104&last_modified=2009-08-25T14:04:57Z&object_type=Exhibit&object_id=104&title=Baker English 227 Project"

		When I search local content with <federation=NINES&section=classroom&sort=title asc&start=5000&max=5> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/locals_results.xsd"
		And the xml search total is "144"
		And the xml number of hits is "0"
