slinky_require('core.coffee')
slinky_require('models.coffee')
slinky_require('server.coffee')
slinky_require('views/main_view.coffee')

App.server = new App.Server

$(window).ready () ->
  App.templates = {}
  dommify = (html) ->
    div = document.createElement('div')
    div.innerHTML = html
    div.childNodes

  _($("script[type='text/x-handlebars-template']")).each (d) ->
    App.templates[d.id] =
      (params) -> dommify Handlebars.compile($(d).html())(params)


