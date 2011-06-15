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

When /^I ([^\s]*) with <([^>]*)>$/ do |verb,obj|
	verb = "search/#{verb}" if verb != 'search'
	param = CGI.escape(obj).gsub("%26", '&').gsub("%3D", '=')	# We want to escape everything except the parameter dividers
	visit "/#{verb}?#{param}"
end

When /^I search local content with <([^>]*)> using xml$/ do |obj|
	param = CGI.escape(obj).gsub("%26", '&').gsub("%3D", '=')	# We want to escape everything except the parameter dividers
	visit "/locals/test_search_good.xml?#{param}"
end

When /^I ([^\s]*) with <([^>]*)> using xml$/ do |verb,obj|
	verb = "search/#{verb}" if verb != 'search'
	param = CGI.escape(obj).gsub("%26", '&').gsub("%3D", '=')	# We want to escape everything except the parameter dividers
	visit "/#{verb}.xml?#{param}"
end

When /^a hacker searches local content with <([^>]*)> using xml$/ do |obj|
	obj = CGI.escape(obj).gsub("%26", '&').gsub("%3D", '=')	# We want to escape everything except the parameter dividers
	visit "/locals/test_search_bad.xml?#{obj}"
end

