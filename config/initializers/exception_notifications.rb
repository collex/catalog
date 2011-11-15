if Rails.env.to_s != 'development'
	config_file = File.join(Rails.root, "config", "site.yml")
	if File.exists?(config_file)
		site_specific = YAML.load_file(config_file)

		CollexCatalog::Application.config.middleware.use ExceptionNotifier,
			:email_prefix => site_specific['exception_notifier']['email_prefix'],
			:sender_address => site_specific['exception_notifier']['sender_address'],
			:exception_recipients => site_specific['exception_notifier']['exception_recipients']
	end
end
