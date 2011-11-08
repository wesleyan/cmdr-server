slinky_require('../core.coffee')
slinky_require('room_list.coffee')
slinky_require('device_list.coffee')

App.ControlView = Backbone.View.extend
  room_list: new App.RoomListView
  device_list: new App.DeviceListView

  render: () ->
    @el = App.templates.control()
    $(".left-pane", @el).html @room_list.render().el
    $(".center-pane", @el).html @device_list.render().el
    this
