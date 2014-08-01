Feature: Admin login

	So that the administrator can update the database portion of the site
	As a the administrator
	I want to have a link to log in on the home page

	Scenario: Log in link
		Given I am not authenticated
		When I go to the home page
		Then I should see "admin"
		And I should not see "Manage genres"

	Scenario: Get to login page
		Given I am not authenticated
		When I go to the home page
		And I follow "admin"
		Then I should be on the login page

	Scenario: Logging in successfully
		Given I am on the login page
		And I have one user "chief@administrator.com" with password "passpass"
		When I fill in "user_email" with "chief@administrator.com"
		And I fill in "user_password" with "passpass"
		And I press "Sign in"
		Then I should see "Signed in successfully"
		And I should be on the home page
		And I should see "Manage genres"

	Scenario: Bad login attempt
		Given I am on the login page
		And I have one user "chief@administrator.com" with password "passpass"
		When I fill in "user_email" with "bad@example.com"
		And I fill in "user_password" with "password"
		And I press "Sign in"
		Then I should be on the login page
		Then I should see "Sign in"

	Scenario: Logged in
		Given I am logged in
		When I go to the home page
		Then I should see "Manage genres"

	Scenario: Logging out
		Given I am logged in
		When I sign out
		Then I should see "Signed out successfully"
		And I should be on the home page
