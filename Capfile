libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

unless respond_to?(:namespace) # cap2 differentiator
  $stderr.puts "Requires capistrano version 2"
  exit 1
end

require 'config/boot'
load DaemonKit.framework_root + '/lib/daemon_kit/deployment/capistrano.rb'
puts DaemonKit.framework_root + '/lib/daemon_kit/deployment/capistrano.rb'
Dir['config/deploy/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy.rb'