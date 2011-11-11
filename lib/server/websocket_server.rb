module Wescontrol
  module RoomtrolServer
    class WebsocketServer
      DB_URL = "http://localhost:5984"
      def initialize
        @db = CouchRest.database("#{DB_URL}/rooms")

        @seq = @db.get("")[:update_seq]

        @state = {
          buildings: @db.get("_design/roomtrol_web").
            view('buildings')["rows"].map{|x| x['value']},
          
          rooms: @db.get("_design/roomtrol_web").
            view('rooms')["rows"].map{|x| x['value']},

          devices: @db.get("_design/roomtrol_web").
            view('devices')["rows"].map{|x| x['value']},

          drivers: CouchRest.database("#{DB_URL}/drivers").
            get("_design/drivers").view("by_name")["rows"].map{|x| x['value']}
        }
      end

      # Starts the websocket server. This is a blocking call if run
      # outside of an EventMachine reactor.
      def run
        AMQP.start(:host => "localhost"){

          @update_channel = EM::Channel.new

          url = "#{DB_URL}/rooms/_changes?feed=continuous&since=#{@seq}&heartbeat=500"
          DaemonKit.logger.debug url
          http = EM::HttpRequest.new(url).get
          http.stream{|chunk|
            msg = JSON.parse chunk rescue nil
            update msg if msg
          }
          http.callback{ DaemonKit.logger.debug "CouchDB connection closed" }

          
          EM::WebSocket.start({
                                :host => "0.0.0.0",
                                :port => 8000
                              }) do |ws|
            ws.onopen { onopen ws }

            ws.onmessage {|json| onmessage ws, json}

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
          buildings: @state[:buildings],
          rooms: @state[:rooms],
          devices: @state[:devices],
          drivers:  @state[:drivers]
        }

        ws.send JSON.dump(init_message)
      end

      def send_update type, update
        update_msg = {
          id: UUIDTools::UUID.random_create.to_s,
          type: "#{type}_changed",
          update: update
        }
        @update_channel.push(update_msg)
      end

      def update change
        url = "#{DB_URL}/rooms/#{change["id"]}"
        http = EM::HttpRequest.new(url).get
        http.callback{
          doc = JSON.parse(http.response)
          view = if    doc["device"] then :devices
                 elsif doc["class"] == "Room" then :rooms
                 elsif doc["class"] == "Building" then :buildings
                 end
          if view
            url = %@#{DB_URL}/rooms/_design/roomtrol_web/_view/#{view}?key="#{doc["_id"]}"@
            http = EM::HttpRequest.new(url).get
            http.callback{
              msg = JSON.parse(http.response)

              doc = msg["rows"].map{|x| x['value']}.first
              i = @state[view].find_index{|d| d["id"] == doc["id"]}
              @state[view][i] = doc
              send_update view.to_s[0..-2], doc
            }
          end
        }
      end
      
      def onmessage ws, json
        msg = JSON.parse json
        case msg["type"]
        when "state_set"
          state_set(msg)
        else
          DaemonKit.logger.debug("Unknown msg: " + msg.inspect)
        end
      end

      def state_set msg
        DaemonKit.logger.debug("State set: " + msg.inspect)
      end
    end
  end
end
