Feature: Search totals

	So that a web site can show how many objects are in the index for searching
	As a federated web site or an anonymous visitor
	I want to get the total number of objects and the total number of archives in the index.

	Scenario: Get solr resources totals
		Given I am not authenticated
		When I go to the totals search index page using xml
		Then I should see "NINES"
		And I should see "400"
		And I should see "12"
		And I should see "18thConnect"
		And I should see "800"
		And I should see "24"
#TODO: how do I better check the return of the xml object?


