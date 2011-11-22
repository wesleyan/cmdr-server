slinky_require('../core.coffee')

App.DeviceListView = Backbone.View.extend
  className: "device-list"

  initialize: () ->
    App.devices.bind "change", @render, this
    App.devices.bind "change:content", @render, this
    App.devices.bind "change:selection", @selection_changed, this

  render: () ->
    devices = App.devices.content?.map (d) ->
      id: d.id
      name: d.get('params').name
      vars: d.display_vars()

    $(@el).html App.templates.device(devices: devices)
    @selection_changed()
    $(".device", @el).click @device_clicked
    this

  device_clicked: (e) ->
    id = $(e.target).closest(".device").attr('id')
    App.devices.select id

  selection_changed: () ->
    $('.device', @el).removeClass 'selected'
    $(".device##{App.devices.selected?.id}").addClass 'selected'
