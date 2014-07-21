require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

Given /^I am not authenticated$/ do
	page.driver.submit :delete, "/users/sign_out", {}
#  visit('/users/sign_out') # ensure that at least
end

When /^I sign out$/ do
	page.driver.submit :delete, "/users/sign_out", {}
end

Given /^I am logged in$/ do
	email = "chief@administrator.com"
	password = "passpass"
	user = User.new
	user.email = email
	user.password = password
	user.password_confirmation = password
	user.save!
  visit path_to('the login page')
  fill_in('user_email', :with => email)
  fill_in('user_password', :with => password)
  click_button('Sign in')
	expect(page).to have_content('Signed in successfully')
 end

Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
	user = User.new
	user.email = email
	user.password = password
	user.password_confirmation = password
	user.save!
end

#Given /^I am a new, authenticated user$/ do
#  email = 'testing@man.net'
#  password = 'secretpass'
#
#  Given %{I have one user "#{email}" with password "#{password}"}
#  And %{I go to login}
#  And %{I fill in "user_email" with "#{email}"}
#  And %{I fill in "user_password" with "#{password}"}
#  And %{I press "Sign in"}
#end
