deploy_type = 'staging'

# We are still using the production environment, to be the same as possible to production, we are just deploying it somewhere else.
set :rails_env, "production"

#
# From here on, this file is the same as the one for production.
#

# Read in the site-specific information so that the initializers can take advantage of it.
config_file = "config/secrets.yml"
if File.exists?(config_file)
	site_specific = YAML.load_file(config_file)['capistrano'][deploy_type]
else
	puts "***"
	puts "*** Failed to load capistrano configuration. Did you create #{config_file} with a capistrano section?"
	puts "***"
	site_specific = nil
end

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, [site_specific['ssh_name']]
role :web, [site_specific['ssh_name']]
role :db,  [site_specific['ssh_name']]

set :deploy_to, site_specific['deploy_to']
set :application, site_specific['ssh_name']

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server site_specific['ssh_name'], user: site_specific['user'], roles: %w{web app db}

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
