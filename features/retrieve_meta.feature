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
		And the xml list is "Victorian Studies Bibliography,The Poetess Archive"
		And the xml list item "Victorian Studies Bibliography" "carousel_description" is "bibliography of over 4,000 entries"
		And the xml list item "Victorian Studies Bibliography" "site_url" is "http://www.letrs.indiana.edu/web/v/victbib"
		And the xml list item "The Poetess Archive" "carousel_image_url" is "/uploads/1/poetess.jpg"

	Scenario: Get Federations
		Given I am not authenticated
		And the standard federations
		When I go to the federations page using xml
		Then the response status should be "200"
		And the xml has the structure "xsd/meta_federations.xsd"
		And the xml list is "NINES,18thConnect"
		And the xml list item "NINES" "thumbnail" contains "/images/nines.png"
