slinky_require('../core.coffee')

App.RoomListView = Backbone.View.extend
  render: () ->
    @el = App.templates.room_list(buildings: App.buildings.toJSON())

    this

  selection_changed: () ->
    $('.rooms li').removeClass 'selected'

