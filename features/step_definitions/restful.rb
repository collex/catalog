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

# All restful routes

When /^I restfully index a "([^"]*)"$/ do |controller|
	visit "/#{controller}"
end

When /^I restfully show "([^"]*)" from "([^"]*)"$/ do |record, controller|
	visit "/#{controller}/#{record}"
end

When /^I restfully new a "([^"]*)"$/ do |controller|
	visit "/#{controller}/new"
end

When /^I restfully edit "([^"]*)" from "([^"]*)"$/ do |record, controller|
	visit "/#{controller}/#{record}/edit"
end

When /^I restfully create a "([^"]*)"$/ do |controller|
	page.driver.post "/#{controller}/new"
end

When /^I restfully update "([^"]*)" from "([^"]*)"$/ do |record, controller|
	page.driver.put "/#{controller}/#{record}"
end

When /^I restfully delete "([^"]*)" from "([^"]*)"$/ do |record, controller|
	page.driver.delete "/#{controller}/#{record}"
end

# Recover from expected exceptions

Then /^when (.*) an error should occur$/ do |action|
	lambda {When action}.should raise_error
end

Then /^when (.*) a routing error should occur$/ do |action|
	lambda {When action}.should raise_error(ActionController::RoutingError)
end

# Test all restful routes for existence at once

Then /^only the routes "([^"]*)" should exist in "([^"]*)"$/ do |routes,controller|
	all = [ 'index', 'show', 'new', 'edit', 'create', 'update', 'delete' ]
	exists = [ false, false, false, false, false, false, false ]
	needs_id = [ false, true, false, true, false, true, true ]
	arr = routes.split(',')
	arr.each {|route|
		i = all.index(route)
		if i == nil
			throw "Route: #{route} is not one of #{all.join(' ')}"
		end
		exists[i] = true
	}

	# TODO: If new doesn't exist, but show does, then the new route is changed to show with an id of new
	# For now, since new is harmless, just always force it
	if exists[1] == true
		exists[2] = true
	end

	all.each_with_index { |action, i|
		#puts action
		if needs_id[i]
			if exists[i]
				When "I restfully #{action} \"id\" from \"#{controller}\""
			else
				Then "when I restfully #{action} \"id\" from \"#{controller}\" a routing error should occur"
			end
		else
			if exists[i]
				When "I restfully #{action} a \"#{controller}\""
			else
				Then "when I restfully #{action} a \"#{controller}\" a routing error should occur"
			end
		end
	}
end

Then /^all routes should exist in "([^"]*)"$/ do |controller|
	Then "only the routes \"index,show,new,edit,create,update,delete\" should exist in \"#{controller}\""
end
