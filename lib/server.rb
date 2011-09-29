# -*- coding: utf-8 -*-
libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'sinatra'
require 'tempfile'
require 'couchrest'
require 'json'
require 'base64'
require 'net/ldap'
require 'server/database'

require 'server/device'
require 'server/device_lib/RS232Device'
require 'server/devices/Projector'
require 'server/devices/VideoSwitcher'
require 'server/devices/Computer'

LOCAL_DEVEL = true
COOKIE_EXPIRE = 24*60*60

class String
  def us
    self.downcase.gsub(" ", "_")
  end
end

module Wescontrol
  module RoomtrolServer
    class AuthServer < Sinatra::Application
      
      configure do
        Database.setup_database
        Database.update_devices
      end
      
      post '/auth/login' do
        puts "Doing login #{LOCAL_DEVEL ? "LOCAL DEVEL!!!!" : ""}"
        json = JSON.parse(request.body.read.to_s)
        username = json["username"]
        password = json["password"]
        couch = CouchRest.database!("http://127.0.0.1:5984/roomtrol_server")
        authenticated = false

        if user = couch.view("auth/users", {:key => username})["rows"][0]
          if LOCAL_DEVEL
            authenticated = (password == "apassword")
            puts "Authentication? #{authenticated}"
          else
            ldap = Net::LDAP.new
            ldap.host = "gwaihir.wesad.wesleyan.edu"
            ldap.auth "#{username}@wesad.wesleyan.edu", password
            authenticated = username && password && username != "" && password != "" && ldap.bind
          end
        end
        if authenticated
          puts "Authenticated"
          #TODO: Figure out a more secure way of generating the token
          token = Digest::SHA1.hexdigest("#{Time.now + Time.now.usec + (rand * 1000-500)}")
          response.set_cookie "auth_token", {:value => token, :expires => Time.now+COOKIE_EXPIRE, :path => "/"}
          user["value"]["auth_token"] = token
          user["value"]["auth_expire"] = (Time.now+COOKIE_EXPIRE).to_i
          couch.save_doc(user["value"])
          {"auth" => "success", "auth_token" => token}.to_json + "\n"
        else
          status 401
          {"auth" => "failed"}.to_json + "\n"
        end
      end
      

      #Expects json like this:
      #{
      # 'room': 'asdf23jlkj34nas',
      # 'record': {couchdb record update goes here}
      #}
      post '/config' do
        json = JSON.parse(request.body.read.to_s)
        json["room"]
      end

      # Use couchdb replication filters to push configuration
      # settings from server to device.  To push configuration
      # documents initiate a POST request with data "room_id" =>
      # room_id_key.
      post '/config/sync' do
        #TODO: debug errors; get config/sync to initiate a sync, then call it from sc.
        db = CouchRest.database('http://localhost:5984/rooms')
        post_json = JSON.parse(request.body.read.to_s)
        puts "Json from post = #{post_json}"
        room_id = post_json["room_id"]
        puts "ROOMID is #{room_id}"
        # Fetch the eigenroom document with port information.
        doc = db.get("_design/wescontrol_web").view("eigenroom_by_roomid", {:key => room_id})['rows'][0]
        if doc
          doc = doc['value']
          data = {"source" => "http://localhost:5984/rooms",
            #"target" => "http://localhost:5984/test_push_db",
            "target" => "http://#{doc["ip_address"]}:#{doc["couchdb_forward_port"]}/rooms",
            "filter" => "wescontrol_web/config_filter",
            "query_params" => {"key" => room_id}}
          puts JSON.dump(data).inspect
          begin
            puts "Pushing configuration documents to device"
            response = RestClient::Request.execute(:method => :post, :url => "http://localhost:5984/_replicate", :payload => data.to_json, :timeout => 30, :headers => {:content_type => :json})

          rescue => e
            puts "Error pushing configuration: #{e}"
          end
          if response
            body response.body
            status response.status
          else 
            body "Response is nil"
            status 500
          end
        else
          #error - doc not found.
          error =  "Failed to receive eigenroom document with room_id #{room_id}"
          puts error
          status 404
          body error

          # get from couch device_id's ip
          # instantiate post
          # need to create replication filterÂ
          # actions, sources, devices all with belongs_to room_id and room_document itself.
          # actions
          #
        end

      end
      post '/graph' do
        puts "Doing graph"
        #db = CouchRest.database("http://localhost:5984/rooms")
        #room = db.get(params[:room])
        #sources = db.get("_design/wescontrol_web").view("sources", :key => params[:room])    
        #devices = db.get("_design/room").view("devices_for_room", :key => params[:room])
        json = session = JSON.parse(request.body.read.to_s)
        sources = json["sources"]
        devices = json["devices"]
        extron = nil
        projector = nil
        
        graph = %Q\digraph F {
        nodesep=0.5;
        rankdir=LR;
        splines=true;
        rank=same;
        bgcolor="transparent";
        fontcolor="#FFFFFF";
        node [shape=record,width=0.1,height=0.1,color="#FFFFFF"];

        sources [label = "Sources|#{
          sources.collect{|source|
            name = source["name"]
            "<#{name.us}>#{name.capitalize}"
          }.join("|")
        }",height=2.5,fontcolor="#FFFFFF"];

        node [width = 1.5];
    
        #{
          devices.collect{|device|
            name = device["name"]
            projector = name if device["driver"] == "NECProjector"
            if device["driver"] == "ExtronVideoSwitcher"
              extron = name
              %Q&#{name.us} [label = "<top>#{name.capitalize}|<i1>Input 1|<i2>Input 2|<i3>Input 3|<i4>Input 4|<i5>Input 5|<i6>Input 6",fontcolor=white]&
            else
              %Q&#{name.us} [label = "<top>#{name.capitalize}",fontcolor=white]&
            end
          }.join("\n\t")
        }

        #{
          sources.collect{|source|
            name = source["name"]
            input = source["input"]
            if input["switcher"] && extron
              "sources:#{name.us} -> #{extron.us}:i#{input["switcher"]} [label = \"#{input["projector"]}\",fontcolor=white, color=white]"
            else
              "sources:#{name.us} -> projector [label = \"#{input["projector"]}\",fontcolor=white,color=white]"
            end
          }.join("\n\t")
        }
    
        #{
          if projector && extron
            "#{extron.us} -> #{projector} [color=white]"
          end
        }
      }
        \
        f = Tempfile.new("graph")
        f.write graph
        f.close
        f.path
        content_type 'application/json'
        puts "Waiting for graph generation"
        svg = `dot -Tsvg #{f.path}`
        JSON.dump({:data => Base64.encode64(svg)})
      end
    end
  end
end
