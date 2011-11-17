slinky_require('control.coffee')
slinky_require('monitor.coffee')
slinky_require('configure.coffee')

App.MainView = Backbone.View.extend
  control_view: new App.ControlView
  monitor_view: new App.MonitorView
  configure_view: new App.ConfigureView

  initialize: () ->
    @current_view = @control_view

  select_control: () ->
    @set_current_view(@control_view)

  select_monitor: () ->
    @set_current_view(@monitor_view)

  select_configure: () ->
    @set_current_view(@configure_view)

  set_current_view: (view) ->
    @current_view = view
    @render()

  render: () ->
    $('#main-view').html @current_view.render().el

    this
