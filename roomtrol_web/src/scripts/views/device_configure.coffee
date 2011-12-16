slinky_require('../core.coffee')

App.DevicesConfigureView = Backbone.View.extend
  initialize: () ->
    App.rooms.bind "change:selection", @render, this
    App.devices.bind "change", @render, this
    App.devices.bind "change:selection", @render, this
    App.devices.bind "change:content", @render, this

  set_up_bindings: (room) ->
    @field_bind "input.name-field", room,
      ((r) -> r.get('params')?.name),
      ((r, v) -> r.set(params: _(r.get('params')).extend(name: v)))

  render: () ->
    @model?.unbind "change", @update
    @model = App.rooms.selected

    if @model
      $(@el).html App.templates.device_configure()
      devices = @model.get('devices').map (d) ->
        id: d.id
        name: d.get('params').name

      $(".device-list", @el).html App.templates.configure_list(items: devices)
      #@set_up_bindings(@model)

    this

  selection_changed: () ->
    $('.device-list', @el).removeClass 'selected'
    $(".device-list li##{App.devices.selected?.id}").addClass 'selected'

  item_clicked: () ->
    id = $(e.target).closest('.item').attr('id')
    App.devices.select id

