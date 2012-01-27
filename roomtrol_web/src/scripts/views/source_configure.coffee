slinky_require('../core.coffee')
slinky_require('configure_list.coffee')
slinky_require('bind_view.coffee')

App.SourcesConfigureView = App.BindView.extend
  initialize: () ->
    App.rooms.bind "change:selection", @render, this
    @configure_list = new App.ConfigureListView(App.sources)
    App.sources.bind "change:selection", @change_selection, this
    @change_selection()

  set_up_bindings: (room) ->
    @unbind_all()
    if @device
      @field_bind "input[name='name']", @device,
        ((r) -> r.get('params')?.name),
        ((r, v) -> r.set(params: _(r.get('params')).extend(name: v)))
      @field_bind "select[name='type']", @device,
        ((r) -> r.driver().type()),
        ((r, v) => @update_drivers(v))
      @field_bind "select[name='driver']", @device,
        ((r) -> r.driver().get('name')),
        ((r, v) => r.set(driver: v); @update_options(v))
      if @driver_options
        _(@driver_options).each (opt) =>
          @field_bind ".options [name='#{opt.name}']", @device,
            ((r) -> r.get('params')?.config?[opt.name]),
            ((r, v) ->
              config = r.get('params')?.config
              config = {} unless config
              config[opt.name] = v
              r.set(params: _(r.get('params')).extend(config: config)))

  change_selection: () ->
    @source = App.sources.selected
    #@set_up_bindings()

  render: () ->
    @model = App.rooms.selected
    if @model
      $(@el).html App.templates.source_configure()
      $(".source-list", @el).html @configure_list.render().el
      #@set_up_bindings(@model)

    this
