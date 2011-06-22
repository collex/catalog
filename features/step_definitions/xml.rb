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
	assert_equal arg1, response['search']['total']
end

Then /^the xml number of hits is "([^"]*)"$/ do |arg1|
	response = get_xml(page)
	# If there is only one element, then the structure created is different, so we need to see if an array was returned.
	if response['search'] && response['search']['results'] && response['search']['results']['result']
		num = response['search']['results']['result'].kind_of?(Array) ? response['search']['results']['result'].length : 1
	else
		num = 0
	end
	assert_equal arg1.to_i, num
end

Then /^the xml hit "([^"]*)" is "([^"]*)"$/ do |index, uri|
	response = get_xml(page)
	assert_equal uri, response['search']['results']['result'][index.to_i]['uri'].strip()
end

Then /^the xml hit "([^"]*)" contains "([^"]*)"$/ do |index, expected|
	response = get_xml(page)
	if response['search']['results']['result'].kind_of?(Hash) && index.to_i == 0
		hit = response['search']['results']['result']
	else
		hit = response['search']['results']['result'][index.to_i]
	end
	arr = expected.split('&')
	expected = {}
	arr.each { |el|
		arr2 = el.split('=')
		expected[arr2[0]] = arr2[1]
	}
	assert_equal expected, hit
end

Then /^the xml hit "([^"]*)" has the text "([^"]*)"$/ do |index, expected|
	response = get_xml(page)
	hit = response['search']['results']['result'][index.to_i]
	expected = expected.gsub('\n', "\n")
	assert_equal hit['text'], expected
end

Then /^the xml xpath "([^"]*)" is "([^"]*)"$/ do |path, value|
	response = get_xml(page)
	arr = path.split('/')
	arr.each { |key|
		if response.kind_of?(Array)
			response = response[key.to_i]
		else
			response = response[key]
		end
	}
	response = response.join(',') if response.kind_of?(Array)
	assert_equal value, response.strip()
end

Then /^the xml xpath "([^"]*)" is <([^>]*)>$/ do |path, value|
	response = get_xml(page)
	arr = path.split('/')
	arr.each { |key|
		response = response[key]
	}
	assert_equal value, response.strip()
end

Then /^the xml number of facets is "([^"]*)"$/ do |arg1|
	response = get_xml(page)
	assert_equal arg1.to_i, response['search']['facets'].length
end

Then /^the xml number of "([^"]*)" facets is "([^"]*)"$/ do |facet, count|
	response = get_xml(page)
	assert_equal count.to_i, response['search']['facets'][facet]['facet'].length
end

Then /^the xml "([^"]*)" facet "([^"]*)" is "([^"]*)"$/ do |type, facet, count|
	response = get_xml(page)
	facets = response['search']['facets'][type]['facet']
	total = -1
	facets.each { |fac|
		if fac['name'] == facet
			total = fac['count']
		end
	}
	assert_equal count, total.to_s
end

Then /^the xml list is "([^"]*)"$/ do |list|
	response = get_xml(page)
	results = []
	response.each {|item, value|
		value.each { |item2, value2|
			value2.each { |item3|
				results.push(item3['name'])
			}
		}
	}
	assert_equal list, results.join(',')
end

Then /^the xml list2 is "([^"]*)"$/ do |list|
	response = get_xml(page)
	results = []
	response.each {|item, value|
		value.each { |item2, value2|
			value2.each { |item3, value3|
				value3.each { |item4|
					results.push(item4['name'])
				}
			}
		}
	}
	assert_equal list, results.join(',')
end

Then /^the xml list item "([^"]*)" "([^"]*)" is "([^"]*)"$/ do |match_item, match_subitem, match|
	response = get_xml(page)
	found = false
	response.each {|top, all|
		all.each { |item, value|
			value.each { |item2|
				if item2['name'] == match_item
					assert_equal match, item2[match_subitem]
					found = true
					break
				end
			}
		}
	}
	if !found
		assert false, "The requested item is not found."
	end
end

Then /^the xml list item "([^"]*)" "([^"]*)" contains "([^"]*)"$/ do |match_item, match_subitem, match|
	response = get_xml(page)
	found = false
	response.each {|top, all|
		all.each { |item, value|
			value.each { |item2|
				if item2['name'] == match_item
					if !item2[match_subitem].include?(match)
						assert_equal match, item2[match_subitem]
					end
					found = true
					break
				end
			}
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

Then /^the xml "([^"]*)" list ((is)|(starts with)) "([^"]*)"$/ do |type, verb, arg1, arg2, match|
	response = get_xml(page)
	if match == ""
		assert_nil response['names'][type]
	else
		match = match.gsub("&quot;", '"')
		found = false
		response.each {|top, all|
			all.each { |item, value|
				if item == type
					results = []
					value.each { |key, val|
						val.each { |val2|
							results.push(val2['name'])
							results.push(val2['occurrences'])
						}
					}
					if verb == 'is'
						assert_equal match, results.join(',')
					else
						assert_equal match, results.join(',')[0..(match.length-1)]
					end
					found = true
					break
				end
			}
		}
		if !found
			assert false, "The requested item is not found."
		end
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

