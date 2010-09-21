require 'json'

# load server addresses from servers.json
servers_file = File.open("#{File.dirname(__FILE__)}/../../servers.json")
exit "No servers.json file found" unless servers_file
servers = JSON.parse(servers_file.read)['servers']
exit "NO servers in servers.json" unless servers
#set :hosts => servers

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"       # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.1'  # Or whatever env you want it to run in.

#set :deploy_to, "/svc/roomtrol-server" # defaults to "/u/apps/#{application}"
set :user, 'roomtrol' # defaults to the currently logged in user
set :daemon_env, 'production'

set :domain, servers[0]
server domain, :app
