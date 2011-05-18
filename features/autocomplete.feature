Feature: Auto completion

	So that a web site can provide a list of choices to the user as they are typing
	As a visitor
	I want to access a list of likely terms that I can present on my page

	Scenario: Do a simple autocomplete
		Given I am not authenticated
		When I autocomplete with <frag=tree&max=30> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"

	Scenario: Do a simple autocomplete with many matches
		Given I am not authenticated
		When I autocomplete with <frag=tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"

	Scenario: Do an autocomplete that starts with quote
		Given I am not authenticated
		When I autocomplete with <frag="tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"

	Scenario: Do an autocomplete with punctuation
		Given I am not authenticated
		When I autocomplete with <frag=etc.> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"


	Scenario: Do an autocomplete with two non-contiguous words
		Given I am not authenticated
		When I autocomplete with <frag=passage time> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"

	Scenario: Do an autocomplete with two consecutive words
		Given I am not authenticated
		When I autocomplete with <frag=same time> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"

	Scenario: Do an autocomplete with other terms already in the search
		Given I am not authenticated
		When I autocomplete with <frag=tree&q=+same> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&a=+estc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&t=+leaves> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&aut=+whitman> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&ed=+john> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&pub=+john> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&y=+1856> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&g=+poetry> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&f=+NINES> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&o=+freeculture> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&o=+ocr> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
		When I autocomplete with <frag=tree&o=+fulltext> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,100,treebeard,5,treetop,34"
