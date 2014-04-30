slinky_require('../core.coffee')

App.SearchView = Backbone.View.extend
  start: () ->
    # search on keyup in search box    
    $("input#room-search").keyup =>
      @search()

    $("input#room-search").click =>
      @search()

  search: () ->
    searchFilter = $("input#room-search").val()

    if searchFilter == ""
      $(".rooms li a").show()
      $(".buildings li a").show()
      return

    # else, do the rest

    # first, hide all
    $(".rooms li a").hide()       # hide rooms
    $(".buildings li > a").hide() # hide buildings

    # get data-search attributes of all rooms
    roomList = $(".rooms li a").map ->
      $(this).attr "data-search"

    roomList = Array::slice.apply roomList #convert jQuery object to array

    # fuzzy search filter the data-search attributes
    fuzzy.filter(searchFilter, roomList).map((r) ->
      r.string
    ).forEach (r) -> #show the filtered ones
      selector = $("*[data-search=\"#{r}\"]")
      selector.show() #show the room itself
      selector.parent().parent().prev("a").show() #show the building