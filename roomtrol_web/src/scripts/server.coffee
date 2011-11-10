slinky_require('websock.coffee')
slinky_require('models.coffee')

class Server
  constructor: () ->
    @websock = new Websock()
    @websock.bind "message", (msg) => @handle_msg msg

    $(window).load =>
      console.log("Connecting to websocket")
      @websock.connect()

  handle_msg: (json) ->
    msg = JSON.parse(json)
    console.log(msg)
    switch msg.type
      when "connection"
        @connected msg
      else
        console.log("Unhandled message type: " + msg.type)


  connected: (msg) ->
    # Initialize our collections
    console.log(msg.buildings)
    App.buildings.reset msg.buildings
    App.rooms.reset msg.rooms
    App.devices.reset msg.devices
    App.drivers.reset msg.drivers

    App.main_view = new App.MainView().render()
App.Server = Server
