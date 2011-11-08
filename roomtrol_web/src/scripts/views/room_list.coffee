slinky_require('../core.coffee')

App.RoomListView = Backbone.View.extend
  initialize: () ->
    App.rooms.bind "change:selection", @selection_changed

  render: () ->
    @el = App.templates.room_list(buildings: App.buildings.toJSON())
    $(".rooms a", @el).click @room_clicked
    console.log $(".rooms a", @el)

    this

  room_clicked: (e) ->
    App.rooms.select e.target.id
    false

  selection_changed: () ->
    $('.rooms li').removeClass 'selected'
    $(".rooms li:has(a##{App.rooms.selected.id})").addClass 'selected'

