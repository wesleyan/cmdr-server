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
      if el.val() != get(model)
        el.val get(model)

    el.keyup () ->
      if el.val() != get(model)
        set(model, el.val())
        model.trigger("change")

   render: () ->
    @model?.unbind "change", @update
    @model = App.rooms.selected

    if @model
      hash =
        buildings: App.buildings.toJSON()
        name: @model.get('params').name

      $(@el).html App.templates.general_configure(hash)

      @set_up_bindings(@model)
      #Backbone.ModelBinding.bind(this)

    this

