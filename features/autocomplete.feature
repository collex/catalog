Feature: Auto completion

	So that a web site can provide a list of choices to the user as they are typing
	As a visitor
	I want to access a list of likely terms that I can present on my page

	Scenario: Do a simple autocomplete
		Given I am not authenticated
		When I autocomplete with <frag=tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,23979,trees,17911,treetops,414,treeless,173,treed,126,treetop,117,treet,73,treesthe,60,treetrunk,56,treethe,53,treetrunks,49,treea,46,treesand,44,treecutting,44,treelined,37"

	Scenario: Do a simple autocomplete with many matches
		Given I am not authenticated
		When I autocomplete with <frag=tree&max=30> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,23979,trees,17911,treetops,414,treeless,173,treed,126,treetop,117,treet,73,treesthe,60,treetrunk,56,treethe,53,treetrunks,49,treea,46,treesand,44,treecutting,44,treelined,37,treen,34,treefelling,33,treeand,31,treefrogs,30,treelike,27,treeshaded,26,treetoad,26,treesa,25,treefrog,24,treeplanting,23,treets,20,treeing,17,treei,17,treestump,17,treeferns,16"

	Scenario: Do an autocomplete that starts with quote
		Given I am not authenticated
		When I autocomplete with <frag="tree> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,23979,trees,17911,treetops,414,treeless,173,treed,126,treetop,117,treet,73,treesthe,60,treetrunk,56,treethe,53,treetrunks,49,treea,46,treesand,44,treecutting,44,treelined,37"

	Scenario: Do an autocomplete with punctuation
		Given I am not authenticated
		When I autocomplete with <frag=etc.> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "etc,42131,etching,761,etchings,685,etched,639,etcher,161,etch,131,etceteras,110,etcetera,102,etcand,95,etcetc,82,etcthe,55,etches,53,etcbut,51,etci,50,etchers,42"


	Scenario: Do an autocomplete with two non-contiguous words
		Given I am not authenticated
		When I autocomplete with <frag=passage time> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is ""

	Scenario: Do an autocomplete with two consecutive words
		Given I am not authenticated
		When I autocomplete with <frag=same time> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is ""

	Scenario: Do an autocomplete with other terms already in the search
		Given I am not authenticated
		When I autocomplete with <frag=tree&q=+same> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,13331,trees,12032,treetops,376,treeless,164,treed,116,treetop,97,treet,67,treesthe,54,treethe,51,treetrunk,46,treetrunks,45,treea,43,treesand,42,treeand,31,treelined,29"
		When I autocomplete with <frag=tree&a=+estc> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "trees,613,tree,500,treetop,5,treeton,4,treen,3,treehorn,2,treeowen,1,treee,1,treebles,1,treet,1,treemess,1,treenails,1"
		When I autocomplete with <frag=tree&t=+leaves> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,63,trees,48,treetoad,8,treetops,6,treesto,3,treesearth,3,treesbuilt,3,treesthe,3,treesthere,2,treetopswind,2,treesnot,1,treesfarborn,1,treeswhere,1,treeswith,1,treescanst,1"
		When I autocomplete with <frag=tree&aut=+nomatch> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is ""
		When I autocomplete with <frag=tree&aut=+whitman> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,11,trees,10,treetoad,7,treetops,5,treesbuilt,3,treesearth,3,treesto,3,treesthe,3,treesthere,2,treetopswind,2,treeswhere,1,treesnot,1,treesfarborn,1,treenorthward,1,treeswith,1"
		When I autocomplete with <frag=tree&ed=+john> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,311,trees,121,treeless,3,treetops,3,treen,3,treeslovely,2,treesill,1,treeprimrose,1,treeabout,1,treelike,1,treegirt,1,treesso,1,treeswere,1,treeton,1,treeintermixed,1"
		When I autocomplete with <frag=tree&pub=+john> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "trees,325,tree,264,treet,4,treetops,3,treed,3,treethe,2,treeton,2,treesthe,2,treesand,1,treehe,1,treei,1,treein,1,treeisland,1,treeislands,1,treemore,1"
		When I autocomplete with <frag=tree&y=+1856> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,45,trees,32,treetops,10,treed,3,treetoad,2,treetop,2,treesim,1,treesand,1,treesas,1,treeone,1,treesnever,1,treesnot,1,treesolemn,1,treeless,1,treebark,1"
		When I autocomplete with <frag=tree&g=+Poetry> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,2088,trees,1141,treetops,15,treetoad,7,treesthe,7,treeen,5,treen,4,treetrunks,4,treecrownd,4,treetwas,3,treesto,3,treecrown,3,treesearth,3,treetop,3,treethe,3"
		When I autocomplete with <frag=tree&f=+NINES> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,22281,trees,16239,treetops,409,treeless,173,treed,120,treetop,112,treet,62,treetrunk,56,treesthe,55,treethe,52,treetrunks,49,treecutting,44,treea,44,treesand,43,treelined,37"
		When I autocomplete with <frag=tree&o=+freeculture> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,2542,trees,1783,treetops,63,treesthe,14,treecourt,14,treetrunks,13,treen,12,treeless,12,treea,12,treethe,11,treesq,10,treet,9,treetoad,9,treetrunk,8,treed,7"
		When I autocomplete with <frag=tree&o=+ocr> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "tree,1001,trees,766,treet,23,treed,15,treea,9,treetop,9,treetrunk,8,treeless,8,treen,7,treeve,6,treetops,6,treeit,5,treenails,5,treesit,5,treeves,4"
		When I autocomplete with <frag=tree&o=-fulltext> using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/autocomplete_results.xsd"
		And the xml autocomplete list is "trees,1359,tree,1294,treetop,7,treeton,6,treen,5,treeowen,2,treehorn,2,treeing,2,treenails,2,treemess,2,treee,1,treedwellers,1,treeitory,1,treene,1,treelined,1"
