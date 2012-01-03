slinky_require('../core.coffee')

App.BindView = Backbone.View.extend
  undo_bindings: []

  field_bind: (field, model, get, set) ->
    el = $(field, @el)

    el_changed = () ->
      if el.val() != get(model)
        set(model, el.val())
        model.trigger("change")

    model_changed = () ->
      if el.val() != get(model)
        el.val get(model)

    # Bind model
    model.bind "change", model_changed
    @undo_bindings.push(() -> model.unbind("change", model_changed))

    # Bind element depending on its type
    if el.is("input")
      el.keyup el_changed
      @undo_bindings.push(() -> el.unbind("keyup", el_changed))
    else if el.is("select")
      el.change el_changed
      @undo_bindings.push(() -> el.unbind("change", el_changed))

    # trigger model change to set initial state
    model_changed()

  unbind_all: () ->
    _(@undo_bindings).each((c) -> c())
    @undo_bindings = []