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

  # This converts things like "this_is_a_name" to "this is a name"
  Handlebars.registerHelper "titleize", (name) -> name.split("_").join(" ")

  # This displays the proper falsey value in the control page
  Handlebars.registerHelper "falsey", (state) -> 
    if state
      state
    else if state == false
      "false"
    else
      ""

  _($("script[type='text/x-handlebars-template']")).each (d) ->
    App.templates[d.id] =
      (params) -> dommify Handlebars.compile($(d).html())(params)


