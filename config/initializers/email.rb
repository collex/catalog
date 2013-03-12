# Initialize everything about email addresses and sending

CONTACT_US_EMAIL = SITE_SPECIFIC['admin']['email']

Rails.application.config.action_mailer.delivery_method = :smtp
ActionMailer::Base.smtp_settings[:enable_starttls_auto] = SITE_SPECIFIC['smtp_settings']['enable_starttls_auto']
ActionMailer::Base.smtp_settings[:address] = SITE_SPECIFIC['smtp_settings']['address']
ActionMailer::Base.smtp_settings[:port] = SITE_SPECIFIC['smtp_settings']['port']
ActionMailer::Base.smtp_settings[:domain] = SITE_SPECIFIC['smtp_settings']['domain']
ActionMailer::Base.smtp_settings[:user_name] = SITE_SPECIFIC['smtp_settings']['user_name']
ActionMailer::Base.smtp_settings[:password] = SITE_SPECIFIC['smtp_settings']['password']
ActionMailer::Base.smtp_settings[:authentication] = SITE_SPECIFIC['smtp_settings']['authentication']
ActionMailer::Base.default_url_options[:host] = SITE_SPECIFIC['smtp_settings']['return_path']

# This is for sendgrid: it helps with the statistics on the sendgrid site.
if SITE_SPECIFIC['smtp_settings']['xsmtpapi'].present?
	ActionMailer::Base.default "X-SMTPAPI" => "{\"category\": \"#{SITE_SPECIFIC['smtp_settings']['xsmtpapi']}\"}"
end
