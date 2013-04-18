module Database
	def self.update_devices
		puts "Updating devices"
		errors = []
		couch = CouchRest.database!("http://127.0.0.1:5984/drivers")
    dir = File.dirname(__FILE__)
		Dir.glob("#{dir}/devices/*.rb").each{|device|
			begin
				require device
				device_string = File.open(device).read
				data = JSON.load(device_string
          .split("\n")
          .collect{|line| line[1..-1]}
          .join("")
          .match(/---(.*)?---/)[1])
        
				if record = couch.view("drivers/by_name", {:key => data["name"]})["rows"][0]
					data["_id"] = record["value"]["_id"]
					data["_rev"] = record["value"]["_rev"]
				end
				data["driver"] = true
				data["config"] = Object.const_get(data["name"]).config_vars
				couch.save_doc(data)
			rescue => e
				errors << "Failed to load #{device}: #{$!}"
			rescue LoadError
				errors << "Failed to load #{device}: syntax error"
			end
		}
		puts errors.join("\n")
	end


	def self.setup_database
		puts "Setting up db"
		rooms = CouchRest.database!("http://127.0.0.1:5984/rooms")
		doc = {
			"_id" => "_design/roomtrol_web",
			:language => "javascript",
			:filters => {
				:device => "function(doc, req) { if(doc.device && !doc.update)return true; return false; }",
				:config_filter => <<eos
function (doc, req) {
  if(((doc.action || doc.source || doc.device) && doc.belongs_to == req.query.key) ||
    (doc.class == "Room" && doc.id == req.query.key)){
    return true;
  }
  else return false; 
}
eos
			},
      
			:views => {
				:buildings => {
					:map => 
            'function(doc){
              if(doc.class && doc.class == "Building" &&
                 doc.attributes && doc.attributes["name"])
              {
                emit(doc._id, {
                  name: doc.attributes["name"],
                  id: doc._id
                });
              }
            }'
        },
        :rooms => {
          :map => <<-eos.strip
            function(doc){
              if(doc.class && doc.class == "Room" && doc.belongs_to){
                emit(doc._id, {
                  id: doc._id,
                  building: doc.belongs_to,
                  params: doc.attributes
                });
              }
            } 
          eos
        },
        :devices => {
          :map => <<-eos.strip
            function(doc){
              if(doc.device && doc.belongs_to && !doc.eigenroom){
                emit(doc._id, doc);
              }
            }
          eos
        },
        "by_source_room" => {
          "map" => <<-eos.strip
            function (doc){
              if(doc.action || doc.source || doc.device){
                emit(doc.belongs_to, doc);
              }
              else if(doc.class == "Room"){
                emit(doc._id, doc);
              }
            }
          eos
        },
				"sources" => {
					"map" => "function(doc) {
						if(doc.source && doc.belongs_to)emit(doc.belongs_to, doc);
					}"
				},
				"actions" => {
					"map"=>"function(doc) {
						if(doc.action && doc.belongs_to)emit(doc.belongs_to, doc);
					}"
				},
				"eigenroom_by_roomid" => {
					"map"=> "function(doc) {
						if(doc.class=='Eigenroom' && doc.room_id) {
						emit(doc.room_id, doc);}
				   }"
				},
				"eigenrooms_nice" => {
					"map"=> "function(doc) {
						if(doc.class=='Eigenroom' && doc.room_id) {
						emit(('Hostname: ' + doc.room_name + ' IP: ' + doc.ip_address) , doc);}
				   }"
				}
			}
		}
		begin 
			doc["_rev"] = rooms.get("_design/roomtrol_web").rev
		rescue
		end
		rooms.save_doc(doc)

		roomtrol_server = CouchRest.database!("http://127.0.0.1:5984/roomtrol_server")
		doc = {
			"_id" => "_design/auth",
			:language => "javascript",
			:views => {
				:users => {
					:map => "function(doc){ if(doc.is_user)emit(doc.username, doc); }"
				},
				:tokens => {
					:map => "function(doc) { if(doc.is_user)emit(doc.auth_token, doc); }"
				}
			}
		}
		begin 
			doc["_rev"] = roomtrol_server.get("_design/auth").rev
		rescue
		end
		roomtrol_server.save_doc(doc)

		drivers = CouchRest.database!("http://127.0.0.1:5984/drivers")
		doc = {
			"_id" => "_design/drivers",
			:language => "javascript",
			:views => {
				:by_name => {
					:map => "function(doc) { if(doc.driver)emit(doc.name, doc); }"
				}
			}
		}
		begin 
			doc["_rev"] = drivers.get("_design/drivers").rev
		rescue
		end
		drivers.save_doc(doc).to_json + "\n"
		
		doc = {
			"_id" => "_design/utils",
			:language => "javascript",
			:views => {
				:nice_view => {
					:map => "function(doc) {\n  if(doc.name)emit(doc.name, doc);\n  else if(doc.attributes && doc.attributes.name)emit(doc.attributes.name, doc);\n  else if(doc.class)emit(doc.class, doc);\n  else emit(doc._id, doc);\n}"  
				}
			}
		}
		begin 
			doc["_rev"] = rooms.get("_design/utils").rev
		rescue
		end
		rooms.save_doc(doc)
	end
end
