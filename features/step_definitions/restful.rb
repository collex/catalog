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
	page.driver.post "/#{controller}"
end

When /^I restfully update "([^"]*)" from "([^"]*)"$/ do |record, controller|
	page.driver.put "/#{controller}/#{record}"
end

When /^I restfully delete "([^"]*)" from "([^"]*)"$/ do |record, controller|
	page.driver.delete "/#{controller}/#{record}"
end

# Recover from expected exceptions

#Then /^I should be on the (.+?) page$/ do |page_name|
#  request.request_uri.should == send("#{page_name.downcase.gsub(' ','_')}_path")
#  response.should be_success
#end

Then /^I should be redirected from "([^"]*)" to the (.+?) page$/ do |source, page_name|
	desired_path = path_to(page_name)
	current_path = URI.parse(current_url).path
	if desired_path != current_path
		reg = page.html.match(/You are being <a href="http:\/\/www\.example\.com(.+)">redirected<\/a>/)
		found_path =  reg && reg.length > 1 ? reg[1] : "UNKNOWN"
		if desired_path != found_path
			puts "Redirecting from #{source}"
		end
		assert_equal desired_path, found_path
	end
end

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

Then /^all routes in "([^"]*)" should redirect to "([^"]*)"$/ do |controller, destination|
	When "I restfully index a \"#{controller}\""
	Then "I should be redirected from \"index\" to the #{destination} page"
	When "I restfully show \"id\" from \"#{controller}\""
	Then "I should be redirected from \"show\" to the #{destination} page"
	When "I restfully new a \"#{controller}\""
	Then "I should be redirected from \"new\" to the #{destination} page"
	When "I restfully edit \"id\" from \"#{controller}\""
	Then "I should be redirected from \"edit\" to the #{destination} page"
	When "I restfully create a \"#{controller}\""
	Then "I should be redirected from \"create\" to the #{destination} page"
	When "I restfully update \"id\" from \"#{controller}\""
	Then "I should be redirected from \"update\" to the #{destination} page"
	When "I restfully delete \"id\" from \"#{controller}\""
	Then "I should be redirected from \"delete\" to the #{destination} page"
end

Then /^all routes in "([^"]*)" except "([^"]*)" should redirect to "([^"]*)"$/ do |controller, exceptions, destination|
	exceptions = exceptions.split(',')

	if !exceptions.include?('index')
		When "I restfully index a \"#{controller}\""
		Then "I should be redirected from \"index\" to the #{destination} page"
	end
	if !exceptions.include?('show')
		When "I restfully show \"id\" from \"#{controller}\""
		Then "I should be redirected from \"show\" to the #{destination} page"
	end
	if !exceptions.include?('new')
		When "I restfully new a \"#{controller}\""
		Then "I should be redirected from \"new\" to the #{destination} page"
	end
	if !exceptions.include?('edit')
		When "I restfully edit \"id\" from \"#{controller}\""
		Then "I should be redirected from \"edit\" to the #{destination} page"
	end
	if !exceptions.include?('create')
		When "I restfully create a \"#{controller}\""
		Then "I should be redirected from \"create\" to the #{destination} page"
	end
	if !exceptions.include?('update')
		When "I restfully update \"id\" from \"#{controller}\""
		Then "I should be redirected from \"update\" to the #{destination} page"
	end
	if !exceptions.include?('delete')
		When "I restfully delete \"id\" from \"#{controller}\""
		Then "I should be redirected from \"delete\" to the #{destination} page"
	end
end
