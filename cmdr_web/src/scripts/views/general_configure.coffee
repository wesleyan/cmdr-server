slinky_require('../core.coffee')
slinky_require('bind_view.coffee')

App.GeneralConfigureView = App.BindView.extend
  initialize: () ->
    App.rooms.bind "change:selection", @render, this

  set_up_bindings: (room) ->
    @unbind_all()
    @field_bind "input.name-field", room,
      ((r) -> r.get('params')?.name),
      ((r, v) -> r.set(params: _(r.get('params')).extend(name: v)))
    @field_bind "select.building-field", room,
      ((r) -> r.get('building')?.id),
      ((r, v) -> r.set(building: v))


  render: () ->
    @model?.unbind "change", @update
    @model = App.rooms.selected

    if @model
      hash =
        buildings: App.buildings.toJSON()
        name: @model.get('params').name

      $(@el).html App.templates.general_configure(hash)

      @set_up_bindings(@model)

    this
