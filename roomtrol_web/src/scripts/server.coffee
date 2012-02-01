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
      when "device_changed"
        @device_changed msg
      else
        console.log("Unhandled message type: " + msg.type)

  connected: (msg) ->
    # Initialize our collections
    App.buildings.reset msg.buildings
    App.rooms.reset msg.rooms
    App.devices.reset msg.devices
    App.drivers.reset msg.drivers
    App.sources.reset msg.sources
    App.actions.reset msg.actions
    @trigger("connected")

  send_message: (msg) ->
    msg['id'] = @createUUID()
    console.log("SENDING: " + JSON.stringify(msg))
    @websock.send(JSON.stringify(msg))
    msg['id']

  device_changed: (msg) ->
    if d = App.devices.get(msg.update?.id)
      d.set(msg.update)
    else
      App.devices.add msg.update

  state_set: (device, variable, value) ->
    msg =
      type: "state_set"
      room: device.get('room')?.id
      device: device.id
      var: variable
      value: value
    @send_message(msg)

  createUUID: () ->
    # http://www.ietf.org/rfc/rfc4122.txt
    s = []
    hexDigits = "0123456789ABCDEF"
    for i in [0..31]
      s[i] = hexDigits.substr(Math.floor(Math.random() * 0x10), 1)

    s[12] = "4" # bits 12-15 of the time_hi_and_version field to 0010
    s[16] = hexDigits.substr((s[16] & 0x3) | 0x8, 1)  # bits 6-7 of the clock_seq_hi_and_reserved to 01

    s.join("");

_.extend(Server.prototype, Backbone.Events)
App.Server = Server
