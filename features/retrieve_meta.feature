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
		And the xml has the structure "xsd/meta_list.xsd"
		And the xml list is "Architecture, Artifact"

	Scenario: Get Archives
		Given I am not authenticated
		And the standard archives
		When I go to the archives page using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/meta_list.xsd"
		And the xml list is "victbib, poetess"
		And the xml list item "victbib" "description" is "bibliography of over 4,000 entries"
		And the xml list item "victbib" "site-url" is "http://www.letrs.indiana.edu/web/v/victbib"
		And the xml list item "victbib" "carousel-image-url" is "http://www.letrs.indiana.edu/web/v/victbib"

	Scenario: Get Federations
		Given I am not authenticated
		And the standard federations
		When I go to the federations page using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/meta_list.xsd"
		And the xml list is "NINES, 18thConnect"
		And the xml list item "NINES" "thumbnail" is "/images/nines.png"
