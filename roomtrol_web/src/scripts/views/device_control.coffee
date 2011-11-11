slinky_require('../core.coffee')

App.DeviceControlView = Backbone.View.extend
  className: 'device-control'

  initialize: () ->
    App.devices.bind "change:selection", () => @render()
    @bound_update = () => @update()

  render: () ->
    @device?.unbind "change", @bound_update
    @device = App.devices.selected
    if @device
      @device.bind "change", @bound_update

      hash =
        name: @device.get('params')?.name
        vars: @device.controllable_vars()

      $(@el).html App.templates.device_control(hash)

      @setup_handlers()
      @update()
    this

  setup_handlers: () ->
    d = App.devices.selected
    _(d?.controllable_vars()).each (v) =>
      el = $("#var-#{v.name}", @el)
      switch v.type
        when "boolean"
          el.find(".button.on").click () ->
            d.state_set(v.name, true)
          el.find(".button.off").click () ->
            d.state_set(v.name, false)
        when "percentage"
          el.find("input").change () ->
            d.state_set(v.name, el.find("input").val())
        when "option"
          el.find("select").change () ->
            d.state_set(v.name, el.find("input").val())

  update: () ->
    _(App.devices.selected?.controllable_vars()).each (v) =>
      el = $("#var-#{v.name}", @el)

      switch v.type
        when "boolean"
          el.find(".button").removeClass "selected"
          selected = if v.state == true then "on" else "off"
          el.find(".button.#{selected}").addClass "selected"
        when "percentage"
          el.find("input").val(v.state)
        when "option"
          el.find("select").val(v.state)
