source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.0'

  gem 'uglifier', '>= 1.0.3'
end

gem 'devise'

gem "rsolr"

gem 'paperclip'

gem 'exception_notification'

#gem 'jquery-rails', '~> 2.1'

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
	#gem "shoulda-matchers" #, "~> 1.0.0"
	#gem 'factory_girl_rails'  #, 1.5.0
	#gem 'simplecov'  #, '0.5.4'
	gem 'rspec-rails'
	gem 'cucumber-rails', :require => false
	gem 'capybara'
	gem 'database_cleaner'
	gem 'launchy'
	gem 'nokogiri'
end
