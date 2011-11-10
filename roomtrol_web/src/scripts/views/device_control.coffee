slinky_require('../core.coffee')

App.DeviceControlView = Backbone.View.extend
  initialize: () ->

  render: () ->
    @el = App.templates.device()
    this
