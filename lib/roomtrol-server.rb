libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)


# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.
require 'eventmachine'
require 'em-proxy'
require 'em-websocket'
require 'amqp'
require 'net/ssh'
require 'dnssd'
require 'thread'
require 'uuidtools'

# lib files
require 'zeroconf'
require 'MAC'
require 'server/websocket_server'


module Wescontrol
  module RoomtrolServer
    class Server
      def initialize
        @db_roomtrol_server = CouchRest.database!("http://127.0.0.1:5984/roomtrol_server")
        @db_rooms = CouchRest.database!("http://127.0.0.1:5984/rooms")
        @couch_forwards = {
          "c180fad1e1599512ea68f1748eb601ea" => 5984
        }
        # Get id of uberroom document, devices should belong to this room.
        @uberroom_id = @db_rooms.get("_design/room").view("by_mac", {:key => MAC.addr})['rows'][0]["id"]
        
        # A map from client room ids to their corresponding daemon ports
        @clients = {}
      end

      def run
        AMQP.start(:host => "localhost") do
          set_up_browser
          set_up_queue
          WebsocketServer.new.run
        end
      end

      def set_up_browser
        EM.defer do
          Thread.abort_on_exception = true
          DaemonKit.logger.debug "Starting browser!!!!"
          browser = DNSSD.browse("_roomtrol2._tcp") do |client_reply|
            #begin - zeroconf detection
            if (client_reply.flags.to_i & DNSSD::Flags::Add) != 0
              
              DaemonKit.logger.debug("DNSSD Add: #{client_reply.inspect}".foreground(:green))
              client = Zeroconf::Client.new client_reply
              client.setup(@db_rooms, @uberroom_id)
              @clients[client.room_id] = client.daemon_port
            else
              DaemonKit.logger.debug("DNSSD Remove: #{client_reply.name}".foreground(:red))
            end
            #end - zeroconf detection
          end
        end
        this = self
      end

      def set_up_queue
        handle_feedback = proc {|feedback, req, resp, job|
          if feedback.is_a? EM::Deferrable
            feedback.callback do |fb|
              @amq_responder.queue(req["queue"]).publish(resp.to_json)
            end
          elsif feedback == nil
            @amq_responder.queue(req["queue"]).publish(resp.to_json)
          else
            resp["result"] = feedback
            @amq_responder.queue(req["queue"]).publish(resp.to_json)
          end
        }

        MQ.new.queue(SERVER_QUEUE).subscribe{|msg|
          req = JSON.parse(msg)
          resp = {:id => req["id"]}
          case req["type"]
          when "state_set"
            handle_feedback.call(state_set(req), req, resp)
          end
        }
      end

      def state_set req
        deferrable = EM::DefaultDeferrable.new
        room = @clients[req["room"]]
        if room.nil?
          deferrable.succeed :error => "room #{room_id} does not exist"
        else
          url = "http://localhost:#{room.daemon_port}/devices/#{req["device"]}/#{req["var"]}"
          data = {:value => msg["value"]}.to_json
          http = EM::HttpRequest.new(url).post(data)
          http.callback{|resp|
            deferrable.succeed JSON.parse(resp)
          }
          http.errback{|err|
            deferrable.succeed :error => "HTTP request to device failed"
          }
        end
        deferrable
      end
      
    end
  end
end
