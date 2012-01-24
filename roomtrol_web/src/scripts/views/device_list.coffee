slinky_require('../core.coffee')

App.DeviceListView = Backbone.View.extend
  className: "device-list"

  initialize: () ->
    App.rooms.bind "change:selection", () => @render()
    App.devices.bind "change:selection", () => @selection_changed()

  render: () ->
    devices = App.rooms.selected?.get('devices').map (d) ->
      id: d.id
      name: d.get('params').name
      vars: d.display_vars()

    console.log(devices)
    $(@el).html App.templates.device(devices: devices)
    $(".device", @el).click @device_clicked
    this

  device_clicked: (e) ->
    console.log(e)
    id = $(e.target).closest(".device").attr('id')
    console.log(id)
    App.devices.select id

  selection_changed: () ->
    $('.device', @el).removeClass 'selected'
    $(".device##{App.devices.selected?.id}").addClass 'selected'
