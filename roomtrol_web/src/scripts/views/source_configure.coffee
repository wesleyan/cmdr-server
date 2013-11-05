slinky_require('../core.coffee')
slinky_require('configure_list.coffee')
slinky_require('bind_view.coffee')

App.SourcesConfigureView = App.BindView.extend
  initialize: () ->
    App.rooms.bind "change:selection", @render, this
    @configure_list = new App.ConfigureListView(App.sources)
    App.sources.bind "change:selection", @change_selection, this
    @configure_list.bind "add", @add, this
    @configure_list.bind "remove", @remove, this
    App.sources.bind "change:update", @render, this
    @change_selection()

  add: () ->
    #msg =
      #_id: App.server.createUUID()
    #  id: id
    #  name: "Unnamed"
    msg = {
      _id: App.server.createUUID()
      name: "Unnamed"
      displayNameBinding: "name"
      input: {
        projector: "HDMI"
        switcher: 0
        video: 0
        audio: 0
      }
      belongs_to: App.rooms.selected.get('id')
      source: true
    }
      #room: App.rooms.selected
      #belongs_to: App.rooms.selected.get('id')

    App.server.create_doc(msg, "source")
    App.sources.add(msg)
    @render

  set_up_bindings: (room) ->
  #  @unbind_all()
  #  if @source
  #    @field_bind "input[name='name']", @source,
  #      ((r) -> r.get('name')),
  #      ((r, v) -> r.set(name: v))
  #    @field_bind "select[name='switcher input']", @source,
  #      ((r) -> if r.get('attributes').input.switcher?
  #                r.get('attributes').input.switcher
  #              else
  #                r.get('attributes').input.video),
  #      ((r, v) => r.set(attributes: _(r.get('attributes')).extend(input['switcher'] = v)))
     # @field_bind "select[name='projector input']", @source,
     #   ((r) -> r.get('attributes').input.projector),
     #   ((r, v) -> r.set(attributes: _(r.get('attributes')).extend(input['projector'] = v)))

  # TODO: Abstract this more
  update_sources: () ->
    switcher = ["1".."8"]
    projector = ["HDMI", "RGB1", "RGB2", "Video", "SVideo"]
    option = (d) -> "<option value=\"#{d}\">#{d}</option>"
    sw = switcher.map(option).join("\n")
    pr = projector.map(option).join("\n")
    $("select[name='switcher input']", @el).html sw
    $("select[name='projector input']", @el).html pr

  change_selection: () ->
    @source = App.sources.selected
    console.log(App.sources.selected)
    @update_sources()
    @set_up_bindings()

  render: () ->
    @model = App.rooms.selected
    if @model
      $(@el).html App.templates.source_configure()
      $(".source-list", @el).html @configure_list.render().el
      @set_up_bindings(@model)

    this
