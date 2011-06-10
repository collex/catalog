@exhibit
Feature: Indexing exhibits

	So that a web site can add peer-reviewed exhibits to the standard index,
	As an authorized website
	I want to send exhibit information to be put into the regular solr index.

	Scenario: Add exhibit, change exhibit, delete exhibit
		Given the standard federations
		When I details with <uri=http://nines.org/peer-reviewed-exhibit/9999> using xml
		Then the response status should be "404"

		When I add the exhibit "federation=NINES&id=9999&title=thetitle&type=partial&genre[]=Book History&genre[]=Poetry"
		Then the response status should be "200"
		When I details with <uri=http://nines.org/peer-reviewed-exhibit/9999> using xml
		Then the response status should be "200"
		And the xml number of hits is "1"
		And the xml xpath "search/results/result/title" is "thetitle"
		And the xml xpath "search/results/result/genre/value" is "Book History,Poetry"

		When I add the exhibit "federation=NINES&id=9999&title=thesecondtitle&type=partial&genre=Book History"
		Then the response status should be "200"
		When I details with <uri=http://nines.org/peer-reviewed-exhibit/9999> using xml
		Then the response status should be "200"
		And the xml number of hits is "1"
		And the xml xpath "search/results/result/title" is "thesecondtitle"

		When I delete the exhibit "federation=NINES&id=9999"
		Then the response status should be "200"
		When I details with <uri=http://nines.org/peer-reviewed-exhibit/9999> using xml
		Then the response status should be "404"

	Scenario: Bad credentials
		Given the standard federations
		When a hacker adds the exhibit "federation=bad&id=9999&title=thesecondtitle"
		Then the response status should be "401"
		When I details with <uri=http://nines.org/peer-reviewed-exhibit/9999> using xml
		Then the response status should be "404"

		When I add the exhibit "federation=NINES&id=9999&title=thetitle"
		Then the response status should be "200"
		When I details with <uri=http://nines.org/peer-reviewed-exhibit/9999> using xml
		Then the response status should be "200"
		And the xml number of hits is "1"
		And the xml xpath "search/results/result/title" is "thetitle"

		When a hacker deletes the exhibit "federation=NINES&id=9999"
		Then the response status should be "401"
		When I details with <uri=http://nines.org/peer-reviewed-exhibit/9999> using xml
		Then the response status should be "200"
		And the xml number of hits is "1"

	Scenario: Bad data
		Given the standard federations
		When I add the exhibit "federation=NINES&id=9999&bad=thesecondtitle"
		Then the response status should be "400"
		When I details with <uri=http://nines.org/peer-reviewed-exhibit/9999> using xml
		Then the response status should be "404"

	Scenario: Add page
		Given the standard federations
		When I details with <uri=http://18thConnect.org/peer-reviewed-exhibit/1818> using xml
		Then the response status should be "404"
		When I details with <uri=http://18thConnect.org/peer-reviewed-exhibit/1818/2> using xml
		Then the response status should be "404"

		When I add the exhibit "federation=18thConnect&id=1818&title=thetitle&type=partial&page=2"
		Then the response status should be "200"

		When I details with <uri=http://18thConnect.org/peer-reviewed-exhibit/1818> using xml
		Then the response status should be "404"
		When I details with <uri=http://18thConnect.org/peer-reviewed-exhibit/1818/2> using xml
		Then the response status should be "200"
		And the xml number of hits is "1"

	Scenario: All fields
		Given the standard federations
		When I search with <q=+smurphtastic> using xml
		Then the response status should be "200"
		And the xml number of hits is "0"

		When I add the exhibit "federation=18thConnect&id=1819&title=thetitle&type=partial&page=2&commit=immediate&alternative=alt&date_label=1799&genre=Poetry&role_AUT=me&role_PBL[]=John&role_PBL=Jane&role_ART=Art&role_TRL=Yvonne&role_EGR=Joseph&role_ETR=Jenn&role_CRE=Chrome&image=http://nines.org/uploads/24.jpg&text=smurphtastic&thumbnail=http://nines.org/uploads/24.jpg&title=Further Adventures&url=http://nines.org/images/thumg.png&year[]=1810&year[]=1811&has_full_text=true&is_ocr=true&freeculture=true&typewright=true"
		
		And I search with <q=+smurphtastic> using xml
		Then the response status should be "200"
		And the xml number of hits is "1"

