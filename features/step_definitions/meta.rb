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

Given /^the standard genres$/ do
	Genre.create!({:name => 'Architecture'})
	Genre.create!({:name => 'Artifacts'})
end

Given /^the standard archives$/ do
	Archive.create!({ :handle => 'victbib', :name => 'Victorian Studies Bibliography', :site_url => 'http://www.letrs.indiana.edu/web/v/victbib' })
	Archive.create!({:handle => 'poetess', :name => 'The Poetess Archive', :site_url => 'http://unixgen.muohio.edu/~poetess/',
		:thumbnail => 'http://unixgen.muohio.edu/~poetess/works/cupidsm.gif',
		:carousel_description => 'The Poetess Archive Database now contains a bibliography of over 4,000 entries for works by and about writers working in and against the "poetess tradition" the extraordinarily popular, but much criticized, flowery poetry written in Britain and America between 1750 and 1900.',
		:carousel_image_url => '/uploads/1/poetess.jpg' })
end

Given /^the standard federations$/ do
	Federation.create!({:name => 'NINES', :thumbnail => '/images/nines.png' })
	Federation.create!({:name => '18thConnect', :thumbnail => '/images/18th_connect.png' })
end

