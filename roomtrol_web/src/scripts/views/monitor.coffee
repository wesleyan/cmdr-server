slinky_require('../core.coffee')

App.MonitorView = Backbone.View.extend
  render: () ->
    @el = App.templates.monitor()
    # $(".left-pane", @el).html @room_list.render().el

    this
