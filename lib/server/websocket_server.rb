module Cmdr
  module CmdrServer
    class WebsocketServer
      # Time to wait for response from server in seconds
      TIMEOUT = 4.0
      
      def initialize
        @db = CouchRest.database("#{DB_URI}/rooms")

        @seq = @db.get("")[:update_seq]

        @state = {
          buildings: @db.get("_design/cmdr_web").
            view('buildings')["rows"].map{|x| x['value']},
          
          rooms: @db.get("_design/cmdr_web").
            view('rooms')["rows"].map{|x| x['value']},

          devices: @db.get("_design/cmdr_web").
            view('devices')["rows"].map{|x| x['value']},

          sources: @db.get("_design/cmdr_web").
            view('sources')["rows"].map{|x| x['value']},

          actions: @db.get("_design/cmdr_web").
            view('actions')["rows"].map{|x| x['value']},
          
          drivers: CouchRest.database("#{DB_URI}/drivers").
            get("_design/drivers").view("by_name")["rows"].map{|x| x['value']}

        }

        @deferred_responses = {}
      end

      # Starts the websocket server. This is a blocking call if run
      # outside of an EventMachine reactor.
      def run
        AMQP.start(:host => "localhost"){

          @update_channel = EM::Channel.new

          url = "#{DB_URI}/rooms/_changes?feed=continuous&since=#{@seq}&heartbeat=500"
          http = EM::HttpRequest.new(url).get
          http.stream{|chunk|
            msg = JSON.parse chunk rescue nil
            update msg if msg
          }
          http.callback{ DaemonKit.logger.debug "CouchDB connection closed" }

          MQ.queue(WEBSOCKET_QUEUE).subscribe{|json|
            #begin
            msg = JSON.parse(json)
            DaemonKit.logger.debug("Websocket:MQ: " + msg.inspect)
              @deferred_responses[msg["id"]].succeed(msg)
            #rescue
            #  DaemonKit.logger.debug "Got error: #{$!}" 
            #end
          }
          
          EM::WebSocket.start({
                                :host => "0.0.0.0",
                                :port => WEBSOCKET_PORT
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
          drivers:  @state[:drivers],
          sources: @state[:sources],
          actions: @state[:actions]
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
        url = "#{DB_URI}/rooms/#{change["id"]}"
        http = EM::HttpRequest.new(url).get
        http.callback{
          doc = JSON.parse(http.response)
          view = if    doc["device"] && ! doc["eigenroom"] then :devices
                 elsif doc["class"] == "Room" then :rooms
                 elsif doc["class"] == "Building" then :buildings
                 elsif doc["action"] then :actions
                 elsif doc["source"] then :sources
                 end
          if view
            url = %@#{DB_URI}/rooms/_design/cmdr_web/_view/#{view}?key="#{doc["_id"]}"@
            http = EM::HttpRequest.new(url).get
            http.callback{
              msg = JSON.parse(http.response)
              doc = msg["rows"].map{|x| x['value']}.first
              i = @state[view].find_index{|d| d["_id"] == doc["_id"]}
              if i
                @state[view][i] = doc
              elsif
                @state[view] << doc
              end
              send_update view.to_s[0..-2], doc
            }
          end
        }
      end

      def onmessage ws, json
        msg = JSON.parse json

        deferrable = EM::DefaultDeferrable.new
        deferrable.callback {|resp|
          resp['id'] = msg['id']
          ws.send resp.to_json
        }
        deferrable.timeout TIMEOUT

        case msg["type"]
        when "state_set"
          state_set(msg, deferrable)
        when "create_doc"
          create_doc(msg, deferrable)
        when "remove_doc"
          remove_doc(msg, deferrable)
        when "save_doc"
          save_doc(msg, deferrable)
        else
          DaemonKit.logger.debug("Unknown msg: " + msg.inspect)
        end
      end

      def state_set msg, df
        DaemonKit.logger.debug("State set: " + msg.inspect)
        req = {
          id: UUIDTools::UUID.random_create.to_s,
          queue: WEBSOCKET_QUEUE,
          type: :state_set,
          room: msg["room"],
          var: msg["var"],
          device: msg["device"],
          value: msg["value"]
        }

        deferrable = EM::DefaultDeferrable.new
        deferrable.timeout TIMEOUT
        deferrable.callback{|result|
          DaemonKit.logger.debug "GOT: <#{result.inspect}>"
          if result["error"]
            df.succeed({:error => result["error"]})
          else
            df.succeed({:ack => true})
          end
        }
        deferrable.errback{|error|
          df.succeed({:error => error})
        }
        @deferred_responses[req[:id]] = deferrable
        MQ.new.queue(SERVER_QUEUE).publish(req.to_json)
      end

      def create_doc msg, df
        req = {
          id: msg["id"],
          queue: WEBSOCKET_QUEUE,
          type: :create_doc,
          doc: msg['doc']
        }
        deferrable = EM::DefaultDeferrable.new
        deferrable.timeout TIMEOUT
        deferrable.callback{|result|
          DaemonKit.logger.debug "GOT: <#{result.inspect}>"
          if result["error"]
            df.succeed({:error => result["error"]})
          else
            df.succeed({:ack => true})
          end
        }
        deferrable.errback{|error|
          df.succeed({:error => error})
        }
        @deferred_responses[req[:id]] = deferrable
        MQ.new.queue(SERVER_QUEUE).publish(req.to_json)
      end

      def remove_doc msg, df
        req = {
          id: msg["id"],
          queue: WEBSOCKET_QUEUE,
          type: :remove_doc,
          doc: msg['doc']
        }
        view = if msg['doc']["action"] then :actions
               elsif msg['doc']['source'] then :sources
               elsif msg['doc']['device'] then :devices
               end
        if view
          @state[view].delete_if {|d| d["_id"] == msg["_id"]}
          send_update view.to_s[0..-2], "remove"
        end
        deferrable = EM::DefaultDeferrable.new
        deferrable.timeout TIMEOUT
        deferrable.callback{|result|
          DaemonKit.logger.debug "GOT: <#{result.inspect}>"
          if result["error"]
            df.succeed({:error => result["error"]})
          else
            df.succeed({:ack => true})
          end
        }
        deferrable.errback{|error|
          df.succeed({:error => error})
        }
        @deferred_responses[req[:id]] = deferrable
        MQ.new.queue(SERVER_QUEUE).publish(req.to_json)
      end

      def save_doc msg, df
        req = {
          id: msg["id"],
          queue: WEBSOCKET_QUEUE,
          type: :save_doc,
          doc: msg['doc']
        }
        deferrable = EM::DefaultDeferrable.new
        deferrable.timeout TIMEOUT
        deferrable.callback{|result|
          DaemonKit.logger.debug "GOT: <#{result.inspect}>"
          if result["error"]
            df.succeed({:error => result["error"]})
          else
            df.succeed({:ack => true})
          end
        }
        deferrable.errback{|error|
          df.succeed({:error => error})
        }
        @deferred_responses[req[:id]] = deferrable
        MQ.new.queue(SERVER_QUEUE).publish(req.to_json)
      end
    end
  end
end
