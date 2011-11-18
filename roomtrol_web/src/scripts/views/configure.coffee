slinky_require('../core.coffee')
slinky_require('room_list.coffee')

App.ConfigureView = Backbone.View.extend
  room_list: new App.RoomListView

  tabs: ["general", "devices", "sources", "actions", "preview"]

  render: () ->
    @el = App.templates.configure(tabs: @tabs)
    $(".left-pane", @el).html @room_list.render().el

    $("#configure-tabs .tab-button a", @el).click (e) => @tab_clicked(e)
    $("#configure-tabs .tab-button", @el).first().addClass "selected"

    this

  tab_clicked: (e) ->
    $("#configure-tabs .tab-button").removeClass "selected"
    $(e.target).parent().addClass "selected"
    name = $(e.target).html()
