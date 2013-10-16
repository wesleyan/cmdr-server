slinky_require('../core.coffee')
slinky_require('configure_list.coffee')
slinky_require('bind_view.coffee')

App.SourcesConfigureView = App.BindView.extend
  initialize: () ->
    App.rooms.bind "change:selection", @render, this
    @configure_list = new App.ConfigureListView(App.sources)
    App.sources.bind "change:selection", @change_selection, this
    @change_selection()


  add: () ->
    App.sources.add
      id: App.server.createUUID()
      name: "Unnamed"
      room: App.rooms.selected
    @render

  set_up_bindings: (room) ->
    @unbind_all()
    if @source
      @field_bind "input[name='name']", @source,
        ((r) -> r.get('name')),
        ((r, v) -> r.set(name: v))
      @field_bind "select[name='switcher input']", @source,
        ((r) -> if r.get('input').switcher?
                  r.get('input').swticher
                else
                  r.get('input').video),
        ((r, v) => r.set(input: _(r.get('input')).extend(switcher: v)))
      @field_bind "select[name='projector input']", @source,
        ((r) -> r.get('input').projector),
        ((r, v) -> r.set(input: _(r.get('input')).extend(projector: v)))

  # TODO: Abstract this more
  update_sources: () ->
    switcher = ["1".."8"]
    projector = ["HDMI", "RGB1", "RGB2", "Video", "SVideo"]
    option = (d) -> "<option value=\"#{d}\">#{d}</option>"
    sw = switcher.map(option).join("\n")
    pr = projector.map(option).join("\n")
    $("select[name='switcher input']", @el).html sw
    $("select[name='projector input']", @el).html pr

  update_projector: () ->
    sources = ["HDMI", "RGB1", "RGB2", "Video", "SVideo"]
    options = source.map((d) -> "<option value=\"#{d}\">#{d}>/option").join("\n")
    $

  change_selection: () ->
    @source = App.sources.selected
    @update_sources()
    @set_up_bindings()

  render: () ->
    @model = App.rooms.selected
    if @model
      $(@el).html App.templates.source_configure()
      $(".source-list", @el).html @configure_list.render().el
      #@set_up_bindings(@model)

    this
