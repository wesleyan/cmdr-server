slinky_require('core.coffee')

# Stub out Backbone.sync, as we're doing all out communication with
# the server over web sockets.
window.Backbone.sync = (method, model, success, error) ->
  true

# This code is largely inspired by Socket.io's client library
class Websock
  connected: no
  connecting: no
  should_reconnect: yes
  ever_connected: no
  options:
    host: "ws://#{window.location.host.split(":")[0]}:8000/"
    # host: "ws://ims-devmac.class.wesleyan.edu:8000/"
    connect_timeout: 1000
    reconnection_delay: 500
    max_delay: 15*1000

  websock_connect: ->
    @ws = new WebSocket(@options.host)

    @ws.onopen = (event) =>
      App.log "Connected to WS"
      this.trigger("connected")
      @connected = yes
      @ever_connected = yes

    @ws.onmessage = (event) =>
      this.trigger("message", event.data)

    @ws.onclose = (event) =>
      this.trigger("disconnected")
      @disconnected()

  send: (msg) ->
    App.log("Sending: %s", msg)
    @ws.send(msg)

  connect: ->
    App.log("Connect!")
    if !@connected
      if @connecting then @disconnect()
      @websock_connect()
      @connect_timeout_timer = setTimeout (=>
        if !@connected
          App.log("Could not connect")
          @disconnect
          this.trigger("connection_failed")
          this.trigger("disconnected")
      ), @options.connect_timeout

  reconnect: ->
    App.log("Reconnecting")
    @reconnecting = true
    @reconnection_attempts = 0
    @reconnection_delay = @options.reconnection_delay
    reset = () =>
      App.log("Resetting")
      if @connected then @trigger("reconnect", @reconnection_events)
      delete this.reconnecting
      delete this.reconnection_attempts
      delete this.reconnection_delay
      delete this.reconnection_timer

    maybe_reconnect = () =>
      if !@reconnecting then return
      if !@connected
        if @connecting && @reconnecting
          return @reconnection_timer = setTimeout(maybe_reconnect, 1000)
        @reconnection_delay *= 2
        max = @options.max_delay
        @reconnection_delay = max if @reconnection_delay > max or @reconnection_delay < 0
        @connect()
        @trigger("reconnecting", [@reconnection_delay, @reconnection_attempts])
        App.log("Reconnection delay: %d s", @reconnection_delay/1000)
        @reconnection_timer = setTimeout(maybe_reconnect, @reconnection_delay)
      else
        reset()
    @reconnection_timer = setTimeout(maybe_reconnect, @reconnection_delay)
    @bind("connect", maybe_reconnect)

  disconnect: ->
    if @connect_timeout_timer then clearTimeout @connect_timeout_timer
    if @ws then @ws.close()

  disconnected: ->
    @was_connected = @connected || !@ever_connected
    @connected = no
    @connecting = no
    if @should_reconnect and !@reconnecting then @reconnect()

_.extend(Websock.prototype, Backbone.Events)
window.Websock = Websock
