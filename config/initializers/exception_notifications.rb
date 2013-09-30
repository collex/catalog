if Rails.env.to_s != 'development'
  CollexCatalog::Application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :email_prefix => Settings.exception_notifier.email_prefix,
    :sender_address => Settings.exception_notifier.sender_address,
    :exception_recipients => Settings.exception_notifier.exception_recipients
  }
end
