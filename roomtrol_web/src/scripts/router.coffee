slinky_require('views/main_view.coffee')

App.Router = Backbone.Router.extend
  main_view: new App.MainView
  initialize: () ->
    App.server.bind "connected", () =>
      @main_view.render()

  routes:
    "":        "configure"
    control:   "control"
    monitor:   "monitor"
    configure: "configure"

  control: () ->
    @main_view.select_tab("control")

  monitor: () ->
    @main_view.select_tab("monitor")

  configure: () ->
    @main_view.select_tab("configure")

