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

def construct_paperclip_entry(fname)
	return { :thumbnail_file_name => fname, :thumbnail_content_type => 'png', :thumbnail_file_size => 2000, :thumbnail_updated_at => Time.now }
end

Given /^the standard genres$/ do
	create_rec(Genre, 1, {:name => 'Architecture'})
	create_rec(Genre, 2, {:name => 'Artifacts'})
end

Given /^the standard archives$/ do
	create_rec(Archive, 1, { :typ => "node",:name => "Journals",:parent_id => "",:carousel_include => "0",
		:carousel_description => ""
	})
	create_rec(Archive, 2, { :typ => "node",:name => "Peer-Reviewed Projects",:parent_id => "",:carousel_include => "0",
		:carousel_description => ""
	})
	create_rec(Archive, 3, { :typ => "archive",:name => "The Rossetti Archive",:parent_id => "2",:carousel_include => "1",
		:carousel_description => "facilitates the scholarly study of Dante Gabriel Rossetti, the painter, designer, writer, and translator who was, according to both John Ruskin and Walter Pater, the most important and original artistic force in the second half of the nineteenth century in Great Britain.",
		:carousel_image_file_name => "photos_small/85/original/rossettiArchive.jpg", :handle => "rossetti", :site_url => "http://www.rossettiarchive.org", :thumbnail => "http://www.rossettiarchive.org/css/whitedgrmotto.gif"
	})
	create_rec(Archive, 4, { :typ => "node",:name => "Library Catalogs",:parent_id => "1",:carousel_include => "0",
		:carousel_description => ""
	})
	create_rec(Archive, 5, { :typ => "archive",:name => "UVA Special Collections",:parent_id => "4",:carousel_include => "0",
		:carousel_description => "",
		:handle => "uva_library", :site_url => "http://www.lib.virginia.edu/small/", :thumbnail => "http://staff.lib.virginia.edu/commpub/resources/new_logos/gif/liblogo_bluetxt.gif	"
	})
#	create_rec(Archive, 1, { :handle => 'victbib', :name => 'Victorian Studies Bibliography', :site_url => 'http://www.letrs.indiana.edu/web/v/victbib', :carousel_description => "bibliography of over 4,000 entries" })
#	create_rec(Archive, 2, {:handle => 'poetess', :name => 'The Poetess Archive', :site_url => 'http://unixgen.muohio.edu/~poetess/',
#		:thumbnail => 'http://unixgen.muohio.edu/~poetess/works/cupidsm.gif',
#		:carousel_description => 'The Poetess Archive Database now contains a bibliography of over 4,000 entries for works by and about writers working in and against the "poetess tradition" the extraordinarily popular, but much criticized, flowery poetry written in Britain and America between 1750 and 1900.',
#		:carousel_image_url => '/uploads/1/poetess.jpg' })
end

Given /^the standard federations$/ do
	create_rec(Federation, 1, {:name => 'NINES', :ip => '9.9.9.9', :site => 'nines.org' }.merge(construct_paperclip_entry('images/nines.png')))
	create_rec(Federation, 2, {:name => '18thConnect', :ip => '18.18.18.18', :site => '18thConnect.org' }.merge(construct_paperclip_entry('images/18th_connect.png')))
end

