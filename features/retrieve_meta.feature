Feature: Retrieve Meta Data

	So that websites can display the friendly names and images for the different assets
	As an anonymous user
	The list of archives, federations, and genres, and their various supporting data should be accessible
	Through an XML interface

	Scenario: Get Genres
		Given I am not authenticated
		And the standard genres
		When I go to the genres page using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/meta_genres.xsd"
		And the xml list is "Architecture,Artifacts"

	Scenario: Get Archives
		Given I am not authenticated
		And the standard archives
		When I go to the archives page using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/meta_archives.xsd"
		And the xml list2 is "Journals,Peer-Reviewed Projects,Library Catalogs,The Rossetti Archive,UVA Special Collections"
		And the xml xpath "resource_tree/nodes/node/0/name" is "Journals"
		And the xml xpath "resource_tree/archives/archive/0/name" is "The Rossetti Archive"
		And the xml xpath "resource_tree/archives/archive/0/carousel/image" is "/system/carousel_images/3/original/photos_small/85/original/rossettiArchive.jpg"

	Scenario: Get Federations
		Given I am not authenticated
		And the standard federations
		When I go to the federations page using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/meta_federations.xsd"
		And the xml list is "NINES,18thConnect"
		And the xml list item "NINES" "thumbnail" contains "/images/nines.png"
