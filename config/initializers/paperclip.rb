# Initialize Paperclip
Paperclip.options[:command_path] = Rails.application.secrets.paperclip['image_magic_path']
Paperclip.options[:swallow_stderr] = false
