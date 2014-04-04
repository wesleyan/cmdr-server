slinky_require('../core.coffee')

App.SearchView = Backbone.View.extend
  initialize: () ->
    $("input#room-search").change ->
      @search()

  search: () ->
    searchFilter = $("input#room-search").val()

    if searchFilter == ""
      $(".rooms li").show()
      $(".buildings li").show()
      return

    # else, do the rest
    roomList = $(".rooms li").map ->
      $(this).attr "data-search"
    
    $(".rooms li").hide()
    $(".buildings li").hide()

    fuzzy.filter(searchFilter, roomList).map((r) ->
      r.string
    ).forEach (r) ->
      selector = $("*[data-search=\"#{r}\"]")
      selector.show() #show the room itself
      selector.parent().parent().parent().show() #show the building