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
  visit('/users/sign_out') # ensure that at least
end

Given /^I am logged in$/ do
	email = "chief@administrator.com"
	password = "passpass"
	User.create!(:email => email, :password => password, :password_confirm => password)
  visit path_to('the login page')
  fill_in('user_email', :with => email)
  fill_in('user_password', :with => password)
  click_button('Sign in')
  if defined?(Spec::Rails::Matchers)
    page.should have_content('Signed in successfully')
  else
    assert page.has_content?('Signed in successfully')
  end
end

Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  User.new(:email => email,
           :password => password,
           :password_confirmation => password).save!
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
