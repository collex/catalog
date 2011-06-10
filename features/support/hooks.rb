Before("@exhibit") do
	solr = Solr.factory_create(true)
	solr.remove_archive("exhibit_*", true)
	When "I search with <a=+exhibit_*> using xml"
	Then 'the response status should be "200"'
	And 'the xml number of hits is "0"'
end

After("@exhibit") do
	solr = Solr.factory_create(true)
	solr.remove_archive("exhibit_*", true)
	When "I search with <a=+exhibit_*> using xml"
	Then 'the response status should be "200"'
	And 'the xml number of hits is "0"'
end
