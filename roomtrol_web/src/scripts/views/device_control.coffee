slinky_require('../core.coffee')

App.DeviceControlView = Backbone.View.extend
  className: 'device-control'

  initialize: () ->
    App.devices.bind "change:selection", () => @render()

  render: () ->
    d = App.devices.selected
    if d
      hash =
        name: d.get('params')?.name
        vars: d.controllable_vars()

      $(@el).html App.templates.device_control(hash)

    this
