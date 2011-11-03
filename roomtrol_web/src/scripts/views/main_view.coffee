slinky_require('control.coffee')

App.MainView = Backbone.View.extend
  current_view: new App.ControlView

  render: () ->
    $('#main-view').html @current_view.render().el
    this
