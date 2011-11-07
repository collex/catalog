config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)

	SOLR_CORE_PREFIX = site_specific['solr']['core_prefix']
	SOLR_URL = site_specific['solr']['url']
	SOLR_PATH = site_specific['solr']['path']
	SVN_COLLEX = site_specific['svn']['url_collex']
	SVN_RDF = site_specific['svn']['url_rdf']
	folders = site_specific['folders']
	if folders
		RDF_PATH = folders['rdf']
		MARC_PATH = folders['marc']
		ECCO_PATH = folders['ecco']
		INDEXER_PATH = folders['rdf_indexer']
	end
	PRODUCTION_SSH = site_specific['production']['ssh']
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end
