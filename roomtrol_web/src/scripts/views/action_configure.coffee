slinky_require('../core.coffee')
slinky_require('configure_list.coffee')
slinky_require('bind_view.coffee')

App.ActionsConfigureView = App.BindView.extend
  initialize: () ->
    App.rooms.bind "change:selection", @render, this
    @configure_list = new App.ConfigureListView(App.actions)
    @configure_list.bind "add", @add, this
    @configure_list.bind "remove", @remove, this
    App.actions.bind "change:selection", @change_selection, this
    App.actions.bind "change:update", @render, this
    @change_selection()

  add: () ->
    #App.actions.add
    msg =
      id: App.server.createUUID()
      #attributes: {name: "Unnamed"}
      name: "Unnamed"
      room: App.rooms.selected
      belongs_to: App.rooms.selected.get('id')

    App.server.create_doc(msg, "action")
    App.actions.add(msg)
    @render()

  set_up_bindings: (room) ->
    @unbind_all()
    if @action
      @field_bind "input[name='name']", @action,
        ((r) -> r.get('name')),
        ((r, v) -> r.set(name: v))
      @field_bind "input[name='prompt projector']", @action,
        ((r) -> r.get('settings')['promptProjector']),
        ((r, v) -> r.set(promptProjector: v))
    #  @field_bind "select[name='type']", @action,
    #    ((r) -> r.driver()?.type()),
    #    ((r, v) => @update_drivers(v))
    #  @field_bind "select[name='driver']", @action,
    #    ((r) -> r.driver()?.get('name')),
    #    ((r, v) => r.set(driver: v); @update_options(v))
    #  if @driver_options
    #    _(@driver_options).each (opt) =>
    #      @field_bind ".options [name='#{opt.name}']", @action,
    #        ((r) -> r.get('attributes')?.config?[opt.name]),
    #        ((r, v) ->
    #          config = r.get('attributes')?.config
    #          config = {} unless config
    #          config[opt.name] = v
    #          r.set(attributes: _(r.get('attributes')).extend(config: config)))

  change_selection: () ->
    @action = App.actions.selected
    #@update_drivers(@action?.driver()?.type())
    #@update_options(@action?.driver()?.get('name'))
    @set_up_bindings()

  #update_drivers: (type) ->
  #  options = _(App.drivers.get_by_type(type))
  #    .chain()
  #    .filter((d) -> not d.get('abstract'))
  #    .invoke("get", "name")
  #    .map((d) -> "<option value=\"#{d}\">#{d}</option>")
  #    .value()
  #    .join("\n")
  #  $("select[name='driver']", @el).html options

  #update_options: (name) ->
  #  driver = App.drivers.get_by_name(name)
  #  if driver
  #    @model = App.rooms.selected
  #    @driver_options = _(driver.options()).map((d) =>
  #        _.extend(_.clone(d), ports: @model.get('params').ports))
  #    hash =
  #      options: @driver_options
  #    $(".options", @el).html(App.templates.driver_options(hash))
  #  @set_up_bindings()

  render: () ->
    @model = App.rooms.selected
    if @model
      $(@el).html App.templates.action_configure()
      $(".action-list", @el).html @configure_list.render().el
      @set_up_bindings(@model)

    this
