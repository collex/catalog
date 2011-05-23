config_file = File.join(Rails.root, "config", "site.yml")
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)

	SITE_NAME_TITLE = site_specific['site_name_title']
else
	puts "***"
	puts "*** Failed to load site configuration. Did you create config/site.yml?"
	puts "***"
end
