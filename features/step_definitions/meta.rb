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

def create_rec(model, idd, hash)
	rec = model.find_by_id(idd)
	if rec
		rec.update_attributes(hash)
		rec.save!
	else
		rec = model.new(hash)
		rec.id = idd
		rec.save(:validate => false)
	end
end

Given /^the standard genres$/ do
	create_rec(Genre, 1, {:name => 'Architecture'})
	create_rec(Genre, 2, {:name => 'Artifacts'})
end

Given /^the standard archives$/ do
	create_rec(Archive, 1, { :handle => 'victbib', :name => 'Victorian Studies Bibliography', :site_url => 'http://www.letrs.indiana.edu/web/v/victbib', :carousel_description => "bibliography of over 4,000 entries" })
	create_rec(Archive, 2, {:handle => 'poetess', :name => 'The Poetess Archive', :site_url => 'http://unixgen.muohio.edu/~poetess/',
		:thumbnail => 'http://unixgen.muohio.edu/~poetess/works/cupidsm.gif',
		:carousel_description => 'The Poetess Archive Database now contains a bibliography of over 4,000 entries for works by and about writers working in and against the "poetess tradition" the extraordinarily popular, but much criticized, flowery poetry written in Britain and America between 1750 and 1900.',
		:carousel_image_url => '/uploads/1/poetess.jpg' })
end

Given /^the standard federations$/ do
	create_rec(Federation, 1, {:name => 'NINES', :thumbnail => '/images/nines.png', :ip => '9.9.9.9', :site => 'nines.org' })
	create_rec(Federation, 2, {:name => '18thConnect', :thumbnail => '/images/18th_connect.png', :ip => '18.18.18.18', :site => '18thConnect.org' })
end

