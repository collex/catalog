# encoding: UTF-8
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

When /^I add the exhibit "([^"]*)"$/ do |exhibit|
	exhibit = CGI.escape(exhibit).gsub("%26", '&').gsub("%3D", '=')	# We want to escape everything except the parameter dividers
	visit "/exhibits/test_create_good.xml?#{exhibit}&commit=immediate"
end

When /^a hacker adds the exhibit "([^"]*)"$/ do |exhibit|
	exhibit = CGI.escape(exhibit).gsub("%26", '&').gsub("%3D", '=')	# We want to escape everything except the parameter dividers
	visit "/exhibits/test_create_bad.xml?#{exhibit}&commit=immediate"
end

When /^I delete the exhibit "([^"]*)"$/ do |exhibit|
	exhibit = CGI.escape(exhibit).gsub("%26", '&').gsub("%3D", '=')	# We want to escape everything except the parameter dividers
	visit "/exhibits/test_destroy_good.xml?#{exhibit}&commit=immediate"
end

When /^a hacker deletes the exhibit "([^"]*)"$/ do |exhibit|
	exhibit = CGI.escape(exhibit).gsub("%26", '&').gsub("%3D", '=')	# We want to escape everything except the parameter dividers
	visit "/exhibits/test_destroy_bad.xml?#{exhibit}&commit=immediate"
end
