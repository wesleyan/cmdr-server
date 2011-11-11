slinky_require('control.coffee')

App.MainView = Backbone.View.extend
  current_view: new App.ControlView

  render: () ->
    $('#main-view').html @current_view.render().el

    $("#99b9b6d7bc4c69844b9b70ff601e3124").click()
    $("#977A97A2-434A-440C-B800-5889BB4367BB").click()
    this
