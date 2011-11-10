slinky_require('../core.coffee')

App.DeviceListView = Backbone.View.extend
  className: "device-list"

  initialize: () ->
    App.rooms.bind "change:selection", () => @render()
    App.rooms.bind "change:selection", @selection_changed

  render: () ->
    devices = App.rooms.selected?.get('devices').toJSON()
      # name: "Projector"
      # vars: [
      #   {name: "Power", value: true},
      #   {name: "Video Mute", value: true},
      #   {name: "Input", value: "RGB"},
      #   {name: "Brightness", value: 0.1},
      #   {name: "Lamp Remaining", value: "50 hours"}
      # ]

    $(@el).html App.templates.device(devices: devices)
    $(".device", @el).click @device_clicked
    this

  device_clicked: (e) ->
    App.devices.select e.target.id

  selection_changed: () ->
    $('.device', @el).removeClass 'selected'
    console.log(".device##{App.devices.selected?.id}")
    $(".device##{App.devices.selected?.id}").addClass 'selected'
