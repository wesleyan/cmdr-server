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
    msg = {
      _id: App.server.createUUID()
      name: "Unnamed"
      belongs_to: App.rooms.selected.get('id')
      displayNameBinding: "name"
      action: true
      settings: {
        promptProjector: false
        source: null
        module: null
      }
    }

    App.server.create_doc(msg)
    App.actions.add(msg)
    @render()

  remove: () ->
    doc = App.actions.selected.attributes
    doc.belongs_to = doc.belongs_to.id
    App.server.remove_doc(doc)
    App.rooms.selected.attributes.actions.remove(App.actions.selected)
    App.actions.remove(App.actions.selected)
    @render

  set_up_bindings: (room) ->
    @unbind_all()
    if @action
      @field_bind "input[name='name']", @action,
        ((r) -> r.get('name')),
        ((r, v) -> r.set(name: v))
      @field_bind "input[name='prompt projector']", @action,
        ((r) -> r.get('settings').promptProjector),
        ((r, v) -> r.set(settings: _(r.get('settings')).extend(promptProjector: v)))

  change_selection: () ->
    @action = App.actions.selected
    @set_up_bindings()

  render: () ->
    @model = App.rooms.selected
    if @model
      $(@el).html App.templates.action_configure()
      $(".action-list", @el).html @configure_list.render().el
      @set_up_bindings(@model)

      $(".save-button", @el).click((e) => @save(e))
      $(".cancel-button", @el).click((e) => @cancel(e))

    this

  save: () ->
    App.server.save_doc(App.actions.selected)

  cancel: () ->
