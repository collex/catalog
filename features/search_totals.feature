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
<objects type="array">
  <object>
    <federation>18thConnect</federation>
    <total type="integer">586911</total>
    <sites type="integer">3</sites>
  </object>
  <object>
    <federation>NINES</federation>
    <total type="integer">288952</total>
    <sites type="integer">8</sites>
  </object>
</objects>
"""

	Scenario: Browse to the solr resources totals
		Given I am not authenticated
		When I go to the totals search index page
		Then the response status should be "200"
		And I should see "18thConnect"
		And I should see "586911"
		And I should see "3"
		And I should see "NINES"
		And I should see "288952"
		And I should see "8"

