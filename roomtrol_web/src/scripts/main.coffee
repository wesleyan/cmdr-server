slinky_require('core.coffee')
slinky_require('models.coffee')
slinky_require('server.coffee')
slinky_require('views/main_view.coffee')

App.server = new App.Server

$(window).ready () ->
  App.templates = {}
  _($("script[type='text/x-handlebars-template']")).each (d) ->
    App.templates[d.id] = Handlebars.compile($(d).html())

