module Wescontrol
  module Server
    class WebsocketServer
      def initialize
        @db = CouchRest.database("http://localhost:5984/rooms")

        @buildings = @db.get("_design/roomtrol_web").
          view('buildings').map{|x| x['value']}

        @rooms = @db.get("_design/roomtrol_web").
          view('rooms').map{|x| x['value']}

        @devices = @db.get("_design/roomtrol_web").
          view('rooms').map{|x| x['value']}

        @drivers = CouchRest.database("http://localhost:5984/rooms").
          get("_design/drivers").map{|x| x['value']}
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
        ws
      end
    end
  end
end
