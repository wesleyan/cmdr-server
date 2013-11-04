libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.
require 'eventmachine'
require 'em-proxy'
require 'em-websocket'
require 'mq'
require 'net/ssh'
require 'dnssd'
require 'thread'
require 'uuidtools'

# lib files
require 'server/zeroconf'
require 'server/MAC'
require 'server/websocket_server'

require 'server/database'
require 'server/device'
require 'server/device_lib/RS232Device'
require 'server/device_lib/SocketDevice'
require 'server/devices/Projector'
require 'server/devices/VideoSwitcher'
require 'server/devices/Computer'
require 'server/devices/SocketProjector'
require 'server/devices/SocketVideoSwitcher'
require 'server/devices/ExtronVideoSwitcher'

module Wescontrol
  module RoomtrolServer
    class Server
      def initialize
        Database.update_devices

        @db_roomtrol_server = CouchRest.database!("http://127.0.0.1:5984/roomtrol_server")
        @db_rooms = CouchRest.database!("http://127.0.0.1:5984/rooms")
        @couch_forwards = {
          "c180fad1e1599512ea68f1748eb601ea" => 5984
        }
        # Get id of uberroom document, devices should belong to this room.
        @uberroom_id = @db_rooms.get("_design/room").view("by_mac", {:key => MAC.addr})['rows'][0]["id"]
        
        # A list of clients
        @clients = []
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
              @clients << client
              DaemonKit.logger.debug(@clients.inspect)
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
              MQ.new.queue(req["queue"]).publish(resp.to_json)
            end
          elsif feedback == nil
            MQ.new.queue(req["queue"]).publish(resp.to_json)
          else
            resp["result"] = feedback
            MQ.new.queue(req["queue"]).publish(resp.to_json)
          end
        }

        MQ.new.queue(SERVER_QUEUE).subscribe{|msg|
          req = JSON.parse(msg)
          resp = {:id => req["id"]}
          case req["type"]
          when "state_set"
            handle_feedback.call(state_set(req), req, resp)
          when "create_doc"
            handle_feedback.call(create_doc(req), req, resp)
          end
        }
      end

      def state_set req
        DaemonKit.logger.debug("REQ: #{req.inspect}")
        deferrable = EM::DefaultDeferrable.new
        room = @clients.find{|r| r.room_id == req["room"]}
        if room.nil?
          deferrable.succeed :error => "room #{req["room"]} does not exist"
        else
          url = "http://localhost:#{room.daemon_port}/devices/#{req["device"]}/#{req["var"]}"
          data = {:value => req["value"]}.to_json
          http = EM::HttpRequest.new(url).post :body => data
          http.callback{
            DaemonKit.logger.debug("GOT: #{http.response}")
            deferrable.succeed JSON.parse(http.response)
          }
          http.errback{
            deferrable.succeed :error => "HTTP request to device failed"
          }
        end
        deferrable
      end

      def create_doc req
        DaemonKit.logger.debug("REQ: #{req.inspect}")
        deferrable = EM::DefaultDeferrable.new
        doc = {
          name: req['name'],
          displayNameBinding: req['displayNameBinding'],
          input: {projector: "HDMI", video: 3},
          belongs_to: req['belongs_to']
        }
        case req['doc_type']
        when "source"
          doc['source'] = true
        when "action"
          doc['action'] = true
        when "device"
          doc['device'] = true
        end
        # TODO: This part should be handled by database. Need to add that functionality
        @db_rooms.save_doc(doc)
        deferrable
      end
    end
  end
end
