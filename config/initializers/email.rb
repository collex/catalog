# Initialize everything about email addresses and sending

CONTACT_US_EMAIL = Rails.application.secrets.admin['email']

Rails.application.config.action_mailer.delivery_method = :smtp
ActionMailer::Base.smtp_settings[:enable_starttls_auto] = Rails.application.secrets.smtp_settings['enable_starttls_auto']
ActionMailer::Base.smtp_settings[:address] = Rails.application.secrets.smtp_settings['address']
ActionMailer::Base.smtp_settings[:port] = Rails.application.secrets.smtp_settings['port']
ActionMailer::Base.smtp_settings[:domain] = Rails.application.secrets.smtp_settings['domain']
ActionMailer::Base.smtp_settings[:user_name] = Rails.application.secrets.smtp_settings['user_name']
ActionMailer::Base.smtp_settings[:password] = Rails.application.secrets.smtp_settings['password']
ActionMailer::Base.smtp_settings[:authentication] = Rails.application.secrets.smtp_settings['authentication']
ActionMailer::Base.default_url_options[:host] = Rails.application.secrets.smtp_settings['return_path']

# This is for sendgrid: it helps with the statistics on the sendgrid site.
if Rails.application.secrets.smtp_settings['xsmtpapi'].present?
	ActionMailer::Base.default "X-SMTPAPI" => "{\"category\": \"#{Rails.application.secrets.smtp_settings['xsmtpapi']}\"}"
end
