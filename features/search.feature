Feature: Normal search

	So that a web site can provide a search capability for any object in solr
	As a federated website, or any other anonymous visitor
	I want to make a search request and receive results from the standard solr index

	Scenario: Do a simple solr search
		Given I am not authenticated
		When I search with <q=+tree> using xml
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

	Scenario: Browse to a simple solr search
		Given I am not authenticated
		When I search with <q=+tree>
		Then the response status should be "200"
		And I should see in this order "18thConnect, 586911, 3, NINES, 288952, 8"

	Scenario: Do a solr search with utf-8
		Given I am not authenticated
		When I search with <q=+Brontë> using xml
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

	Scenario: Do a solr search with apostrophe
		Given I am not authenticated
		When I search for "don't" using xml
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

	Scenario: Do a solr search with quotes
		Given I am not authenticated
		When I search with <q=+"never more"> using xml
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

	Scenario: Do a solr search with mismatched quotes
		Given I am not authenticated
		When I search with <q=+"never more> using xml
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

	Scenario: Do a solr search with multiple terms
		Given I am not authenticated
		When I search with <q=+raven "never more"> using xml
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

	Scenario: Do a solr search with all parameters
		Given I am not authenticated
		When I search with <q=+tree&t=-tree&aut=+John&ed=-quincy&pub=-york&y=-1850&a=-rossetti&g=+poetry&federation=+nines&o=+fulltext&sort=name desc&start=1&max=5&hl=on> using xml
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
