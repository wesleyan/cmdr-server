slinky_require('../core.coffee')
slinky_require('room_list.coffee')

App.ControlView = Backbone.View.extend
  room_list: new App.RoomListView

  render: () ->
    room_list_el = @room_list.render().el
    @el = App.templates.control
      left_pane: room_list_el
    this
