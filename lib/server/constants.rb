module Cmdr
  module CmdrServer
    # SSH username
    SSH_USERNAME = 'cmdr'
    # CouchDB URI
    DB_URI = 'http://localhost:5984'
    # Port to start creating cmdr daemon SSH forwards on
    CMDR_DAEMON_PORT = 10000
    # Port to start creating CouchDB SSH forwards on
    COUCHDB_PORT = 11000
    # Server AMQP queue
    SERVER_QUEUE = "cmdr:server:server"
    # Websocket AMQP queue
    WEBSOCKET_QUEUE = "cmdr:server:websocket"
    # Websocket port
    WEBSOCKET_PORT = 9001
    # MAC address
    MAC = "00:50:56:96:7e:9d"
  end
end
