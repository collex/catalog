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

def strip_weird_html(xml)
	# TODO-PER: There is probably a better way to do this, but we get back an xml doc that is wrapped in
	# HTML, so just remove the parts we don't want. The format is: <!DOCTYPE ... ><?xml ...><html><body><THE REAL STUFF></body></html>
	arr = xml.split("<?xml")
	xml = "<?xml" + arr[1]
	return xml.gsub("<html><body>", "").gsub("</body></html>", "")
end

def validation(document_text, schema_path)
	schema = Nokogiri::XML::Schema(File.read(schema_path))
	document_text = strip_weird_html(document_text)
	document = Nokogiri::XML(document_text)

	err = []
	schema.validate(document).each do |error|
	  err.push(error.message)
	end

	return err
end

Then /^the xml has the structure "([^"]*)"$/ do |schema_path|
	err = validation(page.body, "#{Rails.root}/features/#{schema_path}")
	if err.length > 0
		puts strip_weird_html(page.body)
		assert false, err.join("\n")
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

Then /^the xml list is "([^"]*)"$/ do |list|
	response = get_xml(page)
	results = []
	response.each {|item, value|
		value.each { |item2, value2|
			results.push(item2['name'])
		}
	}
	assert_equal list, results.join(',')
end

Then /^the xml list item "([^"]*)" "([^"]*)" is "([^"]*)"$/ do |match_item, match_subitem, match|
	response = get_xml(page)
	found = false
	response.each {|top, all|
		all.each { |item, value|
			if item['name'] == match_item
				assert_equal match, item[match_subitem]
				found = true
				break
			end
		}
	}
	if !found
		assert false, "The requested item is not found."
	end
end

Then /^the xml autocomplete list is "([^"]*)"$/ do |list|
	response = get_xml(page)
	results = []
	if list == ""
		assert_nil response['autocomplete']
	else
		response = response['autocomplete']['result']
		response.each {|result|
			results.push(result['item'])
			results.push(result['occurrences'])
		}
		assert_equal list, results.join(',')
	end
end

Then /^the xml "([^"]*)" list is "([^"]*)"$/ do |type, match|
	response = get_xml(page)
	found = false
	response.each {|top, all|
		all.each { |item, value|
			if item == type
				results = []
				value.each { |val|
					results.push(val['name'])
					results.push(val['count'])
				}
				assert_equal match, results.join(',')
				found = true
				break
			end
		}
	}
	if !found
		assert false, "The requested item is not found."
	end
end

Then /^the xml "([^"]*)" element array is "([^"]*)"$/ do |keyword, list|
	response = get_xml(page)
	results = []
	response.each {|item, value|
		value.each { |item2, value2|
			value2.each { |value3|
				if value3[keyword] != nil
					results.push(value3[keyword])
				end
			}
		}
	}
	assert_equal list, results.join(',')
end

