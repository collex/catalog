if Rails.env.to_s != 'development'
  CollexCatalog::Application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => SITE_SPECIFIC['exception_notifier']['email_prefix'],
    :sender_address => SITE_SPECIFIC['exception_notifier']['sender_address'],
    :exception_recipients => SITE_SPECIFIC['exception_notifier']['exception_recipients']
  }
end
