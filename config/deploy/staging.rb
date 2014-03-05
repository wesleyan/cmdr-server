#set :deploy_to, "/svc/cmdr-server" # defaults to "/u/apps/#{application}"
#set :user, "cmdr-server"            # defaults to the currently logged in user
set :daemon_env, 'staging'

set :domain, 'example.com'
server domain
