slinky_require('../core.coffee')

App.GeneralConfigureView = Backbone.View.extend
  initialize: () ->
    App.rooms.bind "change:selection", @render, this

  set_up_bindings: (room) ->
    @field_bind "input.name-field", room,
      ((r) -> r.get('params')?.name),
      ((r, v) -> r.set(params: _(r.get('params')).extend(name: v)))

  field_bind: (field, model, get, set) ->
    el = $(field, @el)
    model.bind "change", () ->
      el.val get(model)

    el.keyup () ->
      console.log("SETTING=" + el.val())
      set(model, el.val())

  render: () ->
    @room?.unbind "change", @update
    @room = App.rooms.selected

    if @room
      hash =
        name: @room.get('params')?.name
        buildings: App.buildings.toJSON()

      $(@el).html App.templates.general_configure(hash)

      @set_up_bindings(@room)

    this

