Feature: Auto completion

	So that a web site can provide a list of choices to the user as they are typing
	As a visitor
	I want to access a list of likely terms that I can present on my page

	Scenario: Do a simple autocomplete
		Given I am not authenticated
		When I autocomplete with <frag=tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,23981,trees,17913,treetops,414,treeless,173,treed,126,treetop,117,treet,73,treesthe,60,treetrunk,56,treethe,53,treetrunks,49,treea,46,treesand,44,treecutting,44,treelined,37"

	Scenario: Do a simple autocomplete with many matches
		Given I am not authenticated
		When I autocomplete with <frag=tree&max=30> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,23981,trees,17913,treetops,414,treeless,173,treed,126,treetop,117,treet,73,treesthe,60,treetrunk,56,treethe,53,treetrunks,49,treea,46,treesand,44,treecutting,44,treelined,37,treen,34,treefelling,33,treeand,31,treefrogs,30,treelike,27,treeshaded,26,treetoad,26,treesa,25,treefrog,24,treeplanting,23,treets,20,treeing,17,treei,17,treestump,17,treeferns,16"

	Scenario: Do an autocomplete that starts with quote
		Given I am not authenticated
		When I autocomplete with <frag="tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,23981,trees,17913,treetops,414,treeless,173,treed,126,treetop,117,treet,73,treesthe,60,treetrunk,56,treethe,53,treetrunks,49,treea,46,treesand,44,treecutting,44,treelined,37,treen,34,treefelling,33,treeand,31,treefrogs,30,treelike,27,treeshaded,26,treetoad,26,treesa,25,treefrog,24,treeplanting,23,treets,20,treeing,17,treei,17,treestump,17,treeferns,16"

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
		And the xml autocomplete list is "tree,13332,trees,12033,treetops,376,treeless,164,treed,116,treetop,97,treet,67,treesthe,54,treethe,51,treetrunk,46,treetrunks,45,treea,43,treesand,42,treeand,31,treelined,29"
		When I autocomplete with <frag=tree&a=+estc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "trees,613,tree,500,treetop,5,treeton,4,treen,3,treehorn,2,treeowen,1,treee,1,treebles,1,treet,1,treemess,1,treenails,1"
		When I autocomplete with <frag=tree&t=+leaves> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,65,trees,48,treetoad,8,treetops,6,treesto,3,treesearth,3,treesbuilt,3,treesthe,3,treesthere,2,treetopswind,2,treesnot,1,treesfarborn,1,treeswhere,1,treeswith,1,treescanst,1"
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
