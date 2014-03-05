libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# External dependencies
require 'dnssd'
require 'time'
#require 'couchrest'
require 'rubygems'
require 'net/ssh'
require 'net/http'
require 'socket'

# This will work for now since all uname/pw are the same
# but there should be some sort of handshake on connect
# that establishes the correct credentials
require 'authenticate'

# Internal Cmdr dependencies
require 'constants'

module Cmdr
  module CmdrServer
    # A module for managing interactions with zeroconf devices.
    module Zeroconf
      # Each Client object represents a cmdr device client in a given room.     
      class Client
        attr_reader :daemon_port, :couchdb_port, :room_id
        
        # Initialize Client object. Select a unused port to establish ssh connections
        def initialize client_reply, db_uri=DB_URI
          # name of device broadcasted via zeroconf
          @name = client_reply.name.split[-1]
          @ip_address = self.resolve client_reply

          # See comment in authenticate require
          creds = Authenticate.get_credentials("#{File.dirname(__FILE__)}/../../security")
          @creds = "#{creds['user']}:#{creds['password']}@"
        end

        # Setup a client device. Takes a Couchdb database connection.
        def setup db, uberroom_id
          @db = db
          @uberroom_id = uberroom_id
          # must establish connection to 1412 first
          establish_forwards
          #forward(5984, @ip_address)
        end

        # Fetch a document from couchdb db by roomid, or create it if
        # it doesn't exist.
        def get_doc
          # views returns empty list if no key exits
          doc = @db.get("_design/cmdr_web")
                   .view("eigenroom_by_roomid", {:key => @room_id})['rows'][0]
          if doc
            doc = doc['value']
          else
            doc = {
              belongs_to: @uberroom_id,
              device: true,
              :class => "Eigenroom",
              eigenroom: true,
              room_id: @room_id,
              room_name: @name,
              ip_address: @ip_address
            }
          end
        end

        # Resolves a browser_reply object to a ip address
        # 
        # @param [DNSSD::Reply::Browse] the DNSSD browser reply
        #   object of client device to be resolved.
        # @return [String] the ip address of the resolved client
        def resolve client_reply
          retries = 0
          begin
            # Connect to client and get an ip address.
            #ip = client_reply.connect[0][3]
            client_reply.name.match(/Cmdr client on (.+)/)[1] + ".class"
          rescue
            if retries < 5
              DaemonKit.logger.debug "#{client_reply.inspect}: DNSSD connect failed, retrying...: #{$!}".foreground(:red)
              retries += 1
              retry
            else
              raise "Unable to resolve client: #{client_reply.name}"
            end
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
          # Setup forwarding to client's cmdr-daemon at :1412.
          forward(1412, @ip_address) do |local_host, local_port|
            Thread.abort_on_exception = true
            begin
              url = "http://#{local_host}:#{local_port}/room/"
              @room_id = JSON.parse(RestClient.get(url))["id"]
              DaemonKit.logger.debug("#{@name} has room_id: #{@room_id}".foreground(:green))
            rescue Errno::ECONNREFUSED, RestClient::ResourceNotFound, RestClient::RequestTimeout => e
              DaemonKit.logger.debug("#{@name}: Failed to retrieve RoomID: #{e}".foreground(:red))
            end
            
            # Get document from couchdb by roomid or create it if not in couchdb.
            doc = get_doc
            # Save established connection in couchdb document.
            doc["daemon_forward_port"] = local_port
            doc["last_updated"] = Time.now
            #DaemonKit.logger.debug @db.save_doc(doc)

            @daemon_port = local_port

            forward(5984, @ip_address, 11000) do |local_host, local_port|
              Thread.abort_on_exception = true
              # Setup replication from device's couchdb rooms to server's rooms
              data = {
                _id: "server_replication_#{@room_id}",
                source: "http://#{@creds}#{local_host}:#{local_port}/rooms",
                target: "rooms",
                continuous: true
              }
              DaemonKit.logger.debug "#{@name}: Setting up replication"
              begin
                  DaemonKit.logger.info("Local Host: #{local_host}\n Other data: #{data[:_id]}\n all of data: #{data}")
                  url = "http://#{local_host}:5984/_replicator/#{data[:_id]}"
                  res = RestClient.get(url) rescue nil
                  if res
                    rev = JSON.parse(res)["_rev"]
                    RestClient.delete "#{url}?rev=#{rev}"
                  end
                  res = RestClient.put url, data.to_json, :content_type => :json
                  DaemonKit.logger.debug "#{@name}: Response from couch: #{res}"
              rescue => e
                DaemonKit.logger.debug "#{@name}: ERROR FROM REST".foreground(:red)
                DaemonKit.logger.debug e.response.inspect.foreground(:red)
              end

              doc = get_doc
              # Save established connection in couchdb document.
              doc["couchdb_forward_port"] = local_port
              doc["last_updated"] = Time.now
              # Save changes back to couch.
              save_res = @db.save_doc(doc)
              DaemonKit.logger.debug save_res

              @couchdb_port = local_port
            end
          end

          # Setup forwarding to client's couchdb at :5984
        end

        # Establish port forwarding from a given port on local machine to
        # external port on host. These sessions are used to communicate with
        # CouchDB and cmdr-daemon on the remote client.
        # @param remote_port port on remote host to connect to.
        # @param remote_host host to forward connections to.
        # @param local_port local port to listen on.
        # @param local_host local address to bind to.
        # @param user user account on remote host.
        # Note: passwords are not used. Public/Private keys must be
        # setup on remote and local machines.
        #
        # *Example usage*: Forward traffic from localhost:1234 to user@remote.com:80
        # port_forward(1234, 'cmdr-allb004.class.wesleyan.edu', 80) or
        # port_forward('127.0.0.1', 1234, 'cmdr-allb004.class.wesleyan.edu', 80)
        def forward remote_port, remote_host, local_port=10000, local_host='127.0.0.1', user=SSH_USERNAME
          EM.defer do
            Thread.abort_on_exception = true
            retry_count = 0
            DaemonKit.logger.debug("#{@name}: Attempting to establish port fowarding from #{local_host}:#{local_port} to #{remote_host}:#{remote_port}")
            begin
              if is_port_in_use?('127.0.0.1', local_port)
                puts "PORT IN USE #{local_port}"
              else
                puts "PORT IS NOT IN USE #{local_port}"
              end
              
              Net::SSH.start(remote_host, user) do |ssh|
                #ssh.forward.local(local_port, remote_host, remote_port)
                ssh.forward.local(local_port, remote_host, remote_port)
                EM.defer do
                  yield local_host, local_port
                end
                DaemonKit.logger.debug("#{@name}: Established SSH forwarding.")
                ssh.loop { true }
              end
            rescue Errno::EADDRINUSE 
              #puts "Error, port #{local_port} in use, on retry count #{retry_count}"
              local_port += 2
              retry_count += 1
              retry #unless retry_count > 1000
              exit

              # TODO: implement a port finder
              # try a different port and retry
              
            rescue
              DaemonKit.logger.error "Problem with SSH: #{$!}"
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
            elsif service == :cmdr then CMDR_DAEMON_PORT
            else 10000
            end
          DaemonKit.logger.debug "Port starting at #{begin_port_range}"
          while is_port_in_use?('127.0.0.1', begin_port_range) do
            begin_port_range+=2
            DaemonKit.logger.debug "Incrementing port to #{begin_port_range}"
          end
          DaemonKit.logger.debug begin_port_range
          return begin_port_range
        end

        # Check if a port is in use. Should return instantly on
        # localhost, if doesn't might need to implement a different
        # free port finder.
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
