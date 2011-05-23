config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)

	SOLR_CORE_PREFIX = site_specific['solr']['core_prefix']
	SOLR_URL = site_specific['solr']['url']
	SOLR_PATH = site_specific['solr']['path']
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end
