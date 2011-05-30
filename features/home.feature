Feature: Show Home Page

	So that a user first stumbling on this web service will know how to use it
	As a new visitor
	I want to have a description of how to use the web service when calling the "/" page

	Scenario: Home page as HTML
		When I go to the home page
		Then I should see "Arc Catalog"
