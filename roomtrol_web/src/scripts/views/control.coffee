slinky_require('../core.coffee')
slinky_require('room_list.coffee')
slinky_require('device_list.coffee')
slinky_require('device_control.coffee')

App.ControlView = Backbone.View.extend
  room_list: new App.RoomListView
  device_list: new App.DeviceListView
  device_control: new App.DeviceControlView

  render: () ->
    @el = App.templates.control()
    $(".left-pane", @el).html @room_list.render().el
    $(".center-pane", @el).html @device_list.render().el
    $(".right-pane", @el).html @device_control.render().el
    this
