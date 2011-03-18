libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# External dependencies
require 'dnssd'
require 'couchrest'
require 'rubygems'
require 'net/ssh'
require 'net/http'
require 'socket'

# Internal Wescontrol dependencies
require 'constants'

module Wescontrol
  module RoomtrolServer
    module Zeroconf
      # A module for managing interactions with zeroconf devices.
     
      class Client
        # Each Client object represents a roomtrol device client in a given room.

        # Initialize Client object. Select a unused port to establish ssh connections
        def initialize client_reply, db_uri=DB_URI
          # name of device broadcasted via zeroconf
          @name = client_reply.name
          @ip_address = self.resolve client_reply
        end

        # Setup a client device.
        # takes a Couchdb database connection
        def setup db, uberroom_id
          @db = db
          @uberroom_id = uberroom_id
          # must establish connection to 1412 first
          establish_forwards
          #forward(5984, @ip_address)
        end

        # Resolves a browser_reply object to a ip address
        # 
        # @param [DNSSD::Reply::Browse] the DNSSD browser reply object of client device to be resolved.
        # @return [String] the ip address of the resolved client
        def resolve client_reply
          retried = false
          begin
            # Connect to client and get an ip address.
            ip = client_reply.connect[0][3]
          rescue
            puts "connecet failed, retrying" unless retried
            #TODO log failed resolve
            #TODO only rescue from correct exception, not everything, then retry
            retry
          end
        end

        # Establish port forwarding from local host to client.
        # This is a little tricky, and the order is very specific. First, a
        # port forward to remote:1412 must be established. Using this
        # connection, an http request will be sent through the ssh forward to
        # remote:1412/room which will return the MAC address of remote client
        # device. Then, an entry in local server's CouchdDB will be created
        # with id of client's MAC address and an attribute of daemon_port =>
        # port, where port is local port on server that forwards to
        # remote:1412. Once this is all setup, we setup CouchDB replication.
        def establish_forwards
          # Setup forwarding to client's roomtrol-daemon at :1412.
          puts "Establishing port forwards"
          forward(1412, @ip_address) do |local_host, local_port|
            EM.defer do
              Thread.abort_on_exception = true
              puts "trying to get room_id"
              @room_id = JSON.parse(Net::HTTP.get(URI.parse("http://#{local_host}:#{local_port}/room/")))["id"]
              puts @room_id
              
              # Get document from couchdb or create it if not in couchdb.

              doc = begin
                @db.get(@room_id)
              rescue RestClient::ResourceNotFound
                {'belongs_to' => @uberroom_id, "class" => "Eigenroom", "attributes" => {"room_id" => @room_id, "ip_address" => @ip_address }}
              end
              
              # Save established connectino in couchdb document.
              doc["daemon_forward_port"] = local_port
              puts doc
              @db.save_doc(doc)
              
              forward(5984, @ip_address) do |local_host, local_port|
                EM.defer do
                  Thread.abort_on_exception = true
                  # Setup replication from device's couchdb rooms to server's rooms
                  data = {"source" => "http://#{local_host}:#{local_port}/rooms", "target" => "http://#{local_host}:5984/testrb", "continuous" => true}
                  puts "Setting up replication"
                  begin
                    res = RestClient.post "http://#{local_host}:5984/_replicate", data.to_json, :content_type => :json
                    puts "Response from couch: #{res}"
                  rescue => e
                    puts "ERROR FROM REST"
                    puts e.response
                  end

                  doc = begin
                    @db.get(@room_id)
                  rescue RestClient::ResourceNotFound
                    {'belongs_to' => @uberroom_id, "class" => "Eigenroom", "attributes" => {"room_id" => @room_id, "ip_address" => @ip_address }}
                  end
                  
                  # Save established connectino in couchdb document.
                  doc["couchdb_forward_port"] = local_port
                  puts doc
                  @db.save_doc(doc)
                end
              end
            end
          end

          # Setup forwarding to client's couchdb at :5984

        end

        # Establish port forwarding from a given port on local machine to
        # external port on host. These sessions are used to communicate with
        # CouchDB and roomtrol-daemon on the remote client.
        # @param remote_port port on remote host to connect to.
        # @param remote_host host to forward connections to.
        # @param local_port local port to listen on.
        # @param local_host local address to bind to.
        # @param user user account on remote host.
        # Note: passwords are not used. Public/Private keys must be setup on remote and local machines.
        #
        # *Example usage*: Forward traffic from localhost:1234 to user@remote.com:80
        # port_forward(1234, 'roomtrol-allb004.class.wesleyan.edu', 80) or
        # port_forward('127.0.0.1', 1234, 'roomtrol-allb004.class.wesleyan.edu', 80)
        def forward remote_port, remote_host, local_port=10000, local_host='127.0.0.1', user=SSH_USERNAME
          EM.defer do
            Thread.abort_on_exception = true
            retry_count = 0
            puts "Attempting to establish port fowarding from #{local_host}:#{local_port} to #{remote_host}:#{remote_port}"
            begin
              #if is_port_in_use?('127.0.0.1', local_port) then puts "PORT IN USE #{local_port}" end
              #if !is_port_in_use?('127.0.0.1', local_port) then puts "PORT IS NOT IN USE #{local_port}" end
              Net::SSH.start(remote_host, user) do |ssh|
                ssh.forward.local(local_host, local_port, remote_host, remote_port)
                yield local_host, local_port
                ssh.loop { true }
              end
            rescue Errno::EADDRINUSE 
              puts "Error, port #{local_port} in use"
              local_port += 2
              retry_count += 1
              retry unless retry_count > 1000
              exit

              # TODO: implement a port finder
              # try a different port and retry
              
            end
          end
        end

        # Find a free port to use for a given service
        # @param [Symbol] service type of service to run on port.
        # @return [Integer] an unused port to run service on.
        def get_free_port service
          # Look for ports higher than begin_port_range
          begin_port_range = 
            if service == :couchdb then COUCHDB_PORT
            elsif service == :roomtrol then ROOMTROL_DAEMON_PORT
            else 10000
            end
          puts "Port starting at #{begin_port_range}"
          while is_port_in_use?('127.0.0.1', begin_port_range) do
            begin_port_range+=2
            puts "Incrementing port to #{begin_port_range}"
          end
          puts begin_port_range
          return begin_port_range
        end

        # Check if a port is in use. Should return instantly on localhost, if doesn't might need to implement a different free port finder.
        # @param [String] ip ip to connect to.
        # @param [Integer] port port to check if in use.
        def is_port_in_use?(ip, port)
          begin
            TCPSocket.new(ip, port)
          rescue Errno::ECONNREFUSED
            return false
          end
          return true
        end

      end
    end
  end
end
