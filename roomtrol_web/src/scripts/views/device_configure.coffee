slinky_require('../core.coffee')
slinky_require('configure_list.coffee')
slinky_require('bind_view.coffee')

App.DevicesConfigureView = App.BindView.extend
  initialize: () ->
    App.rooms.bind "change:selection", @render, this
    @configure_list = new App.ConfigureListView(App.devices)
    App.devices.bind "change:selection", @change_selection, this
    @change_selection()

  set_up_bindings: (room) ->
    @unbind_all()
    if @device
      @field_bind "input[name='name']", @device,
        ((r) -> r.get('params')?.name),
        ((r, v) -> r.set(params: _(r.get('params')).extend(name: v)))

  change_selection: () ->
    @device = App.devices.selected
    @set_up_bindings()

  render: () ->
    @model = App.rooms.selected

    if @model
      $(@el).html App.templates.device_configure()
      $(".device-list", @el).html @configure_list.render().el
      #@set_up_bindings(@model)

    this
