libdir = ::File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'server'
use Rack::ShowExceptions

run Wescontrol::RoomtrolServer::AuthServer.new
