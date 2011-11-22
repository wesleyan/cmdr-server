slinky_require('../core.coffee')

App.RoomListView = Backbone.View.extend
  initialize: () ->
    App.rooms.bind "change", () => @render()
    App.rooms.bind "change:selection", @selection_changed

  render: () ->
    buildings = App.buildings.map (b) ->
      id: b.id
      name: b.get('name')
      rooms: b.get('rooms').chain()
                           .sortBy((r) -> r.get('params')?.name)
                           .invoke("toJSON")
                           .value()

    console.log(buildings)

    @el = App.templates.room_list(buildings: buildings)
    $(".rooms a", @el).click @room_clicked
    @selection_changed()

    this

  room_clicked: (e) ->
    App.rooms.select e.target.id
    false

  selection_changed: () ->
    $('.rooms li', @el).removeClass 'selected'
    $(".rooms li:has(a##{App.rooms.selected.id})", @el).addClass 'selected'

