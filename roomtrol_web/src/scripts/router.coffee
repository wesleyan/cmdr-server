slinky_require('views/main_view.coffee')

App.Router = Backbone.Router.extend
  main_view: new App.MainView()

  initialize: () ->
    @main_view.render()
    App.server.bind "connected", () =>
      @main_view.render()

  routes:
    "":        "control"
    control:   "control"
    monitor:   "monitor"
    configure: "configure"

  select_tab: (tab) ->
    $(".tab-button").removeClass("selected")
    $(".tab-button##{tab}-button").addClass("selected")

  control: () ->
    @select_tab("control")
    @main_view.select_control()

  monitor: () ->
    @select_tab("monitor")
    @main_view.select_monitor()

  configure: () ->
    @select_tab("configure")
    @main_view.select_configure()

