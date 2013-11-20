slinky_require('../core.coffee')
slinky_require('room_list.coffee')
slinky_require('general_configure.coffee')
slinky_require('device_configure.coffee')
slinky_require('source_configure.coffee')
slinky_require('action_configure.coffee')

App.ConfigureView = Backbone.View.extend
  room_list: new App.RoomListView

  tabs: ["general", "devices", "sources", "actions", "preview"]

  initialize: () ->
    @select_tab @tabs[1]

  select_tab: (tab) ->
    @selected_tab = tab
    $("#configure-tabs .tab-button", @el).removeClass "selected"
    $("#configure-tabs .tab-button.#{tab}-tab", @el).addClass "selected"

    view = App[tab[0].toUpperCase() + tab.slice(1) + "ConfigureView"]
    if view
      $("#configure-view #configure-content", @el).html (new view).render().el
    else
      $("#configure-view #configure-content", @el).html "<h1>not implemented</h1>"

  render: () ->
    $(@el).html App.templates.configure(tabs: @tabs)
    $(".left-pane", @el).html @room_list.render().el

    $("#configure-tabs .tab-button a", @el).click (e) => @tab_clicked(e)

    @select_tab(@selected_tab)
    
    $(".save-button", @el).click((e) => @save_clicked(e))
    $(".discard-button", @el).click((e) => @discard_clicked(e))

    this

  tab_clicked: (e) ->
    @select_tab $(e.target).html()

  #cases on @selected tab
  save_clicked: (e) ->
    switch @selected_tab
      when "general" then App.general.trigger("change:save")
      when "devices" then App.devices.trigger("change:save")
      when "sources" then App.sources.trigger("change:save")
      when "actions" then App.actions.trigger("change:save")

  discard_clicked: (e) ->
    switch @selected_tab
      when "general" then App.general.trigger("change:discard")
      when "devices" then App.devices.trigger("change:discard")
      when "sources" then App.sources.trigger("change:discard")
      when "actions" then App.actions.trigger("change:discard")

