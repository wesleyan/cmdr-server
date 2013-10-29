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
      when "create_doc"
        @create_doc msg
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

  create_doc: (msg) ->
    
    
  device_changed: (msg) ->
    if d = App.devices.get(msg.update?.id)
      d.set(msg.update)
    else
      App.devices.add msg.update

  state_set: (device, variable, value) ->
    msg =
      type: "state_set"
      #room: device.get('room')?.id
      room: device.get('belongs_to')?.id
      device: device.id
      var: variable
      value: value
    @send_message(msg)

  configure: (conf) ->
    @send_message(conf)

  createUUID: () ->
    cryptoUUID = () ->
      # If we have a cryptographically secure PRNG, use that
      buf = new Uint16Array(8)
      window.crypto.getRandomValues(buf)
      S4 = (num) ->
        ret = num.toString(16)
        while ret.length < 4
           ret = "0"+ret
        ret
      (S4(buf[0])+S4(buf[1])+"-"+S4(buf[2])+"-"+S4(buf[3])+"-"+S4(buf[4])+"-"+S4(buf[5])+S4(buf[6])+S4(buf[7]))

    randomUUID = () ->
      # Otherwise, just use Math.random
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
          r = Math.random()*16|0
          v = if c == 'x' then r or (r&0x3|0x8)
          v.toString(16)

    if window.crypto?.getRandomValues
      cryptoUUID()
    else
      randomUUID()

_.extend(Server.prototype, Backbone.Events)
App.Server = Server
