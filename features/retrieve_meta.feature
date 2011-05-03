Feature: Retrieve Meta Data

	So that websites can display the friendly names and images for the different assets
	As an anonymous user
	The list of archives, federations, and genres, and their various supporting data should be accessible
	Through an XML interface

	Scenario: Get Genres
		Given I am not authenticated
		And the standard genres
		When I go to the genres page using xml
		Then I should see "Architecture"
		And I should see "Artifact"

	Scenario: Get Archives
		Given I am not authenticated
		And the standard archives
		When I go to the archives page using xml
		Then I should see "victbib"
		And I should see "poetess"
		And I should see "bibliography of over 4,000 entries"
		And I should see "http://www.letrs.indiana.edu/web/v/victbib"
#		And I should see "<site-url>"
#		And I should see "<carousel-image-url>"

	Scenario: Get Federations
		Given I am not authenticated
		And the standard federations
		When I go to the federations page using xml
		Then I should see "NINES"
		And I should see "18thConnect"
		And I should see "/images/nines.png"

