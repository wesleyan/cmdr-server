module Wescontrol
  module RoomtrolServer
    class WebsocketServer
      def initialize
        @db = CouchRest.database("http://localhost:5984/rooms")

        @buildings = @db.get("_design/roomtrol_web").
          view('buildings')["rows"].map{|x| x['value']}

        @rooms = @db.get("_design/roomtrol_web").
          view('rooms')["rows"].map{|x| x['value']}

        @devices = @db.get("_design/roomtrol_web").
          view('rooms')["rows"].map{|x| x['value']}

        @drivers = CouchRest.database("http://localhost:5984/drivers").
          get("_design/drivers").view("by_name")["rows"].map{|x| x['value']}
      end

      # Starts the websocket server. This is a blocking call if run
      # outside of an EventMachine reactor.
      def run
        AMQP.start(:host => "localhost"){

          @update_channel = EM::Channel.new
          
          EM::WebSocket.start({
                                :host => "0.0.0.0",
                                :port => 8000
                              }) do |ws|
            ws.onopen { onopen ws }

            ws.onmessage {|json| onmessage ws, jon}

            ws.onclose {
              DaemonKit.logger.debug("Connection on #{ws.signature} closed")
            }
          end
        }
      end

      def onopen ws
        @sid = @update_channel.subscribe{|msg|
          ws.send msg.to_json
        }

        init_message = {
          id: UUIDTools::UUID.random_create.to_s,
          type: 'connection',
          bulidings: @buildings,
          rooms: @rooms,
          devices: @devices,
          drivers:  @drivers
        }

        ws.send JSON.dump(init_message)
      end

      def onmessage ws, json
      end
    end
  end
end
