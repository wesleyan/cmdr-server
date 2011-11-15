module Wescontrol
  module RoomtrolServer
    # SSH username
    SSH_USERNAME = 'roomtrol'
    # CouchDB URI
    DB_URI = 'http://localhost:5984'
    # Port to start creating roomtrol daemon SSH forwards on
    ROOMTROL_DAEMON_PORT = 10000
    # Port to start creating CouchDB SSH forwards on
    COUCHDB_PORT = 11000
    # Server AMQP queue
    SERVER_QUEUE = "roomtrol:server:server"
    # Websocket AMQP queue
    WEBSOCKET_QUEUE = "roomtrol:server:websocket"
    # Websocket port
    WEBSOCKET_PORT = 8000
  end
end
