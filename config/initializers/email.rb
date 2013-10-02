# Initialize everything about email addresses and sending

CONTACT_US_EMAIL = Settings.admin.email

Rails.application.config.action_mailer.delivery_method = :smtp
ActionMailer::Base.smtp_settings[:enable_starttls_auto] = Settings.smtp_settings.enable_starttls_auto
ActionMailer::Base.smtp_settings[:address] = Settings.smtp_settings.address
ActionMailer::Base.smtp_settings[:port] = Settings.smtp_settings.port
ActionMailer::Base.smtp_settings[:domain] = Settings.smtp_settings.domain
ActionMailer::Base.smtp_settings[:user_name] = Settings.smtp_settings.user_name
ActionMailer::Base.smtp_settings[:password] = Settings.smtp_settings.password
ActionMailer::Base.smtp_settings[:authentication] = Settings.smtp_settings.authentication
ActionMailer::Base.default_url_options[:host] = Settings.smtp_settings.return_path

# This is for sendgrid: it helps with the statistics on the sendgrid site.
if Settings.smtp_settings.xsmtpapi.present?
	ActionMailer::Base.default "X-SMTPAPI" => "{\"category\": \"#{Settings.smtp_settings.xsmtpapi}\"}"
end
