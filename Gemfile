source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.3.13'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

gem 'rest-client'
gem 'fast-stemmer'
gem 'libxml-ruby'
gem 'devise'

gem "rsolr"

gem 'paperclip'

gem 'exception_notification'

# Use Capistrano for deployment
gem 'capistrano', require: false, group: :development
gem 'capistrano-rvm', group: :development

group :development do
	gem 'capistrano-rails', require: false
	gem 'capistrano-bundler', require: false
end

# Libraries to perform commandline tasks
gem "net-scp"

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
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

