slinky_require('../core.coffee')

App.ConfigureListView = Backbone.View.extend
  initialize: (@controller) ->
    @controller.bind "change", @render, this
    @controller.bind "change:content", @render, this
    @controller.bind "change:selection", @selection_changed, this

  render: () ->
    items = @controller.content?.map (c) ->
      id: c.id
      name: c.get('params').name

    $(@el).html App.templates.configure_list(items: items)
    $(".item a", @el).click((e) => @item_clicked(e))
    @selection_changed()

    this

  item_clicked: (e) ->
    @controller.select e.target.id
    false

  selection_changed: () ->
    $('li', @el).removeClass 'selected'
    $("li:has(a##{@controller.selected?.id})", @el).addClass 'selected'
