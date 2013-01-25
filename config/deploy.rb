# To deploy:
# cap edge
# cap production

require 'rvm/capistrano'

require 'bundler/capistrano'
#require "delayed/recipes"
#require "whenever/capistrano"

# Read in the site-specific information so that the initializers can take advantage of it.
config_file = "config/capistrano.yml"
if File.exists?(config_file)
	set :site_specific, YAML.load_file(config_file)
else
	puts "***"
	puts "*** Failed to load capistrano configuration. Did you create #{config_file}?"
	puts "***"
end

set :repository, "git://github.com/collex/catalog.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache

set :use_sudo, false

set :normalize_asset_timestamps, false

set :rails_env, "production"

#set :whenever_command, "bundle exec whenever"

def set_application(section, skin)
	set :deploy_to, "#{site_specific[section]['deploy_base']}/#{skin}"
	set :application, site_specific[section]['ssh_name']
	set :user, site_specific[section]['user']
	set :rvm_ruby_string, site_specific[section]['ruby']
	if site_specific[section]['system_rvm']
		set :rvm_type, :system
	end

	role :web, "#{application}"                          # Your HTTP server, Apache/etc
	role :app, "#{application}"                          # This may be the same as your `Web` server
	role :db,  "#{application}", :primary => true 		# This is where Rails migrations will run
	set :skin, skin
end

desc "Run tasks in edge environment."
task :edge do
	set_application('edge_tamu', 'catalog')
end

desc "Run tasks in production environment."
task :production do
	set_application('prod_tamu', 'catalog')
end

namespace :passenger do
	desc "Restart Application"
	task :restart do
		run "touch #{current_path}/tmp/restart.txt"
	end
end

namespace :config do
	desc "Config Symlinks"
	task :symlinks do
		run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
		run "ln -nfs #{shared_path}/config/site.yml #{release_path}/config/site.yml"
	end
end

namespace :copy_files do
	desc "Copy all xsd files to the public path"
	task :xsd do
		puts "Updating xsd files..."
		source_dir = "#{release_path}/features/xsd"
		dest_dir = "#{release_path}/public/xsd"
		run "cp -R #{source_dir} #{dest_dir}"
	end
end

after :edge, 'deploy'
after :production, 'deploy'
after :deploy, "deploy:migrate"

#after "deploy:stop",    "delayed_job:stop"
#after "deploy:start",   "delayed_job:start"
#after "deploy:restart", "delayed_job:restart"
after "deploy:finalize_update", "config:symlinks"
after "deploy:finalize_update", "copy_files:xsd"
after :deploy, "passenger:restart"
