slinky_require('../core.coffee')
slinky_require('room_list.coffee')

App.ConfigureView = Backbone.View.extend
  room_list: new App.RoomListView

  render: () ->
    @el = App.templates.configure()
    $(".left-pane", @el).html @room_list.render().el

    this
