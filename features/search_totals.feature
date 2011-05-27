Feature: Search totals

	So that a web site can show how many objects are in the index for searching
	As a federated web site or an anonymous visitor
	I want to get the total number of objects and the total number of archives in the index.

	Scenario: Get solr resources totals
		Given I am not authenticated
		When I go to the totals search index page using xml
		Then the response status should be "200"
		And I should see the following xml:
"""
<?xml version="1.0" encoding="UTF-8"?>
<totals>
	<federation>
		<name>18thConnect</name>
		<total>586911</total>
		<sites>3</sites>
	</federation>
	<federation>
		<name>NINES</name>
		<total>288952</total>
		<sites>8</sites>
	</federation>
</totals>
"""

	Scenario: Browse to the solr resources totals
		Given I am not authenticated
		When I go to the totals search index page
		Then the response status should be "200"
		And I should see in this order "18thConnect, 586911, 3, NINES, 288952, 8"

