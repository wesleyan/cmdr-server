slinky_require('../core.coffee')

App.RoomListView = Backbone.View.extend
  initialize: () ->
    App.rooms.bind "change", () => @render()
    App.rooms.bind "change:selection", @selection_changed

  html_bind: (selector, model, get) ->
    el = $(selector, @el)
    model.bind "change", () ->
      el.html get(model)

  render: () ->
    buildings = App.buildings.map (b) ->
      id: b.id
      name: b.get('name')
      rooms: b.get('rooms').chain()
                           .sortBy((r) -> r.get('params')?.name)
                           .invoke("toJSON")
                           .value()


    $(@el).html App.templates.room_list(buildings: buildings)
    $(".rooms a", @el).click @room_clicked
    @selection_changed()

    get = (r) -> r.get('params')?.name
    App.buildings.each (b) =>
      b.get('rooms').each (r) =>
        @html_bind("#" + r.id, r, get)

    this

  room_clicked: (e) ->
    App.rooms.select e.target.id
    false

  selection_changed: () ->
    $('.rooms li', @el).removeClass 'selected'
    $(".rooms li:has(a##{App.rooms.selected.id})", @el).addClass 'selected'

