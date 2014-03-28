slinky_require('../core.coffee')

App.SearchView = Backbone.View.extend
  initialize: () ->
    rooms = $(".rooms li").map ->
      $(this).attr "data-search"
    
    $(".rooms li").hide()
    $(".buildings li").hide()

    fuzzy.filter($("input#room-search").val(), rooms).map((r) ->
      r.string
    ).forEach (r) ->
      selector = $("*[data-search=\"#{r}\"]")
      selector.show()
      selector.parent().parent().parent().show()