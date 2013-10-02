# Read in the site-specific information so that the initializers can take advantage of it.
CONFIG_FILE = File.join(File.dirname(__FILE__), "..", "site.yml")
unless File.exists?(CONFIG_FILE)
  puts "***"
  puts "*** Failed to load site configuration. Did you create #{config_file}?"
  puts "***"
end

class Settings < Settingslogic
  source Rails.env.test? ? "#{Rails.root}/config/site.example.yml" : CONFIG_FILE
  namespace Rails.env
  suppress_errors Rails.env.test?
  load!
end

# Default settings
##########################
### SKIN
##########################
Settings['site_name_title'] ||= "Arc Catalog"

##########################
### SYSTEM
##########################
Settings['paperclip'] ||= Settingslogic.new({})
Settings.paperclip['image_magic_path'] = File.expand_path(Settings.paperclip['image_magic_path'] || "/usr/bin")

##########################
### EMAIL
##########################
Settings['admin'] ||= Settingslogic.new({})
Settings.admin['email'] ||= "vicky@performantsoftware.com"

##########################
### EXCEPTION NOTIFICATION
##########################
Settings['exception_notifier'] ||= Settingslogic.new({})
Settings.exception_notifier['exception_recipients'] ||= ["root@localhost"]
Settings.exception_notifier['sender_address'] ||= '"Arc Catalog" <arc@localhost>'
Settings.exception_notifier['email_prefix'] ||= "[Project] "

##########################
### SMTP
##########################
Settings['smtp_settings'] ||= Settingslogic.new({})
Settings.smtp_settings['address'] ||= "smtp.gmail.com"
Settings.smtp_settings['port'] ||= 587
Settings.smtp_settings['user_name'] ||= 'admin@example.com'
Settings.smtp_settings['password'] ||= 'super-secret'
Settings.smtp_settings['authentication'] ||= :plain
Settings.smtp_settings['return_path'] ||= "http://example.com"
Settings.smtp_settings['enable_starttls_auto'] ||= true
Settings.smtp_settings['xsmtpapi'] ||= 'catalog'
Settings.smtp_settings['domain'] ||= 'catalog.ar-c.org'

Settings['project_manager_email'] ||= "manager example com"

##########################
### SOLR
##########################
Settings['solr'] ||= Settingslogic.new({})
Settings.solr['url'] ||= "http://localhost:8983/solr"
Settings.solr['core_prefix'] ||= "localhost:8983/solr"
Settings.solr['path'] = File.expand_path(Settings.solr['path'] || "~/solr")

##########################
### FOLDERS
##########################
Settings['folders'] ||= Settingslogic.new({})
Settings.folders['rdf'] = File.expand_path(Settings.folders['rdf'] || "~/rdf")
Settings.folders['marc'] = File.expand_path(Settings.folders['marc'] || "~/marc")
Settings.folders['ecco'] = File.expand_path(Settings.folders['ecco'] || "~/ecco")
Settings.folders['rdf_indexer'] = File.expand_path(Settings.folders['rdf_indexer'] || "~/rdf-indexer")
Settings.folders['backups'] = File.expand_path(Settings.folders['backups'] || "~/backups")
Settings.folders['uploaded_data'] = File.expand_path(Settings.folders['uploaded_data'] || "~/uploaded_data")
Settings.folders['tasks_send_method'] ||= "scp"
Settings.folders['tamu_key'] ||= 'private-token'

##########################
### PRODUCTION
##########################
Settings['production'] ||= Settingslogic.new({})
Settings.production['ssh_user'] ||= "nines"
Settings.production['ssh_host'] ||= "arc.performantsoftware.com"

##########################
### CAPISTRANO
##########################
Settings['capistrano'] ||= Settingslogic.new({})
Settings.capistrano['edge'] ||= Settingslogic.new({})
Settings.capistrano['prod'] ||= Settingslogic.new({})
Settings.capistrano.edge['user'] ||= "arc"
Settings.capistrano.edge['ssh_name'] ||= "ssh-name-to-login-to-server"
Settings.capistrano.edge['ruby'] ||= "ruby-1.9.3-p374@catalog"
Settings.capistrano.edge['system_rvm'] ||= false
Settings.capistrano.edge['deploy_base'] = File.expand_path(Settings.capistrano.edge['deploy_base'] || "/home/arc/www")
Settings.capistrano.prod['user'] ||= "arc"
Settings.capistrano.prod['ssh_name'] ||= "ssh-name-to-login-to-server"
Settings.capistrano.prod['ruby'] ||= "ruby-1.9.3-p374@catalog"
Settings.capistrano.prod['system_rvm'] ||= false
Settings.capistrano.prod['deploy_base'] = File.expand_path(Settings.capistrano.prod['deploy_base'] || "/home/arc/www")
