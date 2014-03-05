slinky_require('core.coffee')
slinky_require('models.coffee')
slinky_require('server.coffee')
slinky_require('router.coffee')

$(window).ready () ->
  App.templates = {}
  dommify = (html) ->
    div = document.createElement('div')
    div.innerHTML = html
    div.childNodes

  # This converts things like "this_is_a_name" to "this is a name"
  Handlebars.registerHelper "titleize", (name) -> name.split("_").join(" ")

  # This displays the proper falsey value in the control page
  Handlebars.registerHelper "falsey", (state) -> 
    if state
      state
    else if state == false
      "false"
    else
      "&nbsp;"

  _($("script[type='text/x-handlebars-template']")).each (d) ->
    App.templates[d.id] =
      (params) -> dommify Handlebars.compile($(d).html())(params)

  App.server = new App.Server
  App.router = new App.Router()
  Backbone.history.start()

