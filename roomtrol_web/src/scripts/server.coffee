slinky_require('websock.coffee')

class Server
  constructor: () ->
    @websock = new Websock()
    @websock.options.host = "ws://localhost:8000"
    @websock.bind "message", (msg) => @handle_msg msg

    $(window).load =>
      console.log("Connecting to websocket")
      @websock.connect()

  handle_msg: (msg) ->
    msg = JSON.parse(json)
    console.log(msg)
    switch msg.type
      when "connection"
        @connected msg
      else
        console.log("Unhandled message type: " + msg.type)


  connected: (msg) ->
    console.log("Got connection")

App.Server = Server
