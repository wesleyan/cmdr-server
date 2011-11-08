slinky_require('../core.coffee')

App.DeviceListView = Backbone.View.extend
  initialize: () ->
    #App.devices.bind "change:selection", @selection_changed

  render: () ->
    hash =
      name: "Projector"
      vars: [
        {name: "Power", value: true},
        {name: "Video Mute", value: true},
        {name: "Input", value: "RGB"},
        {name: "Brightness", value: 0.1},
        {name: "Lamp Remaining", value: "50 hours"}
      ]

    @el = App.templates.device(hash)
    this
