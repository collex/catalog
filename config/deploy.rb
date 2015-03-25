# To deploy:
# cap staging deploy
# cap production deploy

# Read in the site-specific information so that the initializers can take advantage of it.
config_file = "config/secrets.yml"
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)['capistrano']
else
	puts "***"
	puts "*** Failed to load capistrano configuration. Did you create #{config_file} with a capistrano section?"
	puts "***"
	site_specific = nil
end

# config valid only for Capistrano 3.1
lock '3.4.0'

set :repo_url, site_specific['repository']

set :branch, "master"
set :stages, ["staging", "production"]
# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
		# Restarts Phusion Passenger
		execute :touch, release_path.join('tmp/restart.txt')

		# convenient place to put the copy command. This copies some files from the test folders to a public place, so that users can download them.
		puts "Updating xsd files..."
		source_dir = "#{release_path}/features/xsd"
		dest_dir = "#{release_path}/public/xsd"
		execute :cp, "-R #{source_dir} #{dest_dir}"
    end
  end
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
