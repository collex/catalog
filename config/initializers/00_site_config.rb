site_yaml = File.join(Rails.root, "config/site.yml")

if File.exists?(site_yaml)
  SITE_CONFIG = YAML.load_file(site_yaml)
end
