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

require 'nokogiri'

def dump_response(page, response)
	puts "----------------"
	puts page.body
	puts "----------------"
	puts response
	puts "----------------"
end

def get_xml(page)
	# TODO-PER: Why is the returned page wrapped in html here but not if you do the same request as a curl?
	response = Hash.from_xml(page.body)
	return response['html']['body']
end

Then /^I should see the following xml:/ do |xml_output|
  response = get_xml(page)
  expected = Hash.from_xml(xml_output)
  response.diff(expected).should == {}
end

def validation(document_text, schema_path, root_element='')
	schema = Nokogiri::XML::Schema(File.read(schema_path))
	document = Nokogiri::XML(document_text)
	err = schema.validate(document.xpath("//#{root_element}").to_s)
	return err
end

Then /^the xml has the structure "([^"]*)"$/ do |schema_path|
	err = validation(page.body, "#{Rails.root}/features/#{schema_path}", 'objects')
	if err.length > 0
		errs = []
		err.each { |e|
			errs.push(e.message)
		}
		puts errs.join("\n")
		assert false
	end
end

Then /^the xml search total is "([^"]*)"$/ do |arg1|
	response = get_xml(page)
	assert_equal arg1.to_i, response['hash']['total']
end

Then /^the xml number of hits is "([^"]*)"$/ do |arg1|
	response = get_xml(page)
	assert_equal arg1.to_i, response['hash']['hits'].length
end

Then /^the xml hit "([^"]*)" is "([^"]*)"$/ do |index, uri|
	response = get_xml(page)
	assert_equal uri, response['hash']['hits'][index.to_i]['uri']
end

Then /^the xml number of facets is "([^"]*)"$/ do |arg1|
	response = get_xml(page)
	assert_equal arg1.to_i, response['hash']['facets'].length
end

Then /^the xml number of "([^"]*)" facets is "([^"]*)"$/ do |facet, count|
	response = get_xml(page)
	assert_equal count.to_i, response['hash']['facets'][facet].length
end

Then /^the xml "([^"]*)" facet "([^"]*)" is "([^"]*)"$/ do |type, facet, count|
	response = get_xml(page)
	facets = response['hash']['facets'][type]
	total = -1
	facets.each { |fac|
		if fac['name'] == facet
			total = fac['count']
		end
	}
	assert_equal count.to_i, total
end
