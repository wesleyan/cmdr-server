#set :deploy_to, "/svc/roomtrol-server" # defaults to "/u/apps/#{application}"
#set :user, "roomtrol-server"            # defaults to the currently logged in user
set :daemon_env, 'staging'

set :domain, 'example.com'
server domain
