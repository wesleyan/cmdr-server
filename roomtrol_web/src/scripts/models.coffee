slinky_require('core.coffee')

App.SelectionCollection = Backbone.Collection.extend
  select: (id) ->
    item = this.get(id)
    if item
      @selected = item
      @trigger("change:selection")
      item.trigger("selected")

##### BUILDINGS

App.Building = Backbone.RelationalModel.extend
  relations: [
    type: Backbone.HasMany,
    key: 'rooms',
    relatedModel: 'App.Room',
    collectionType: 'App.RoomController'
    reverseRelation:
      key: 'building',
      includeInJSON: 'id'
    ]


App.BuildingController = Backbone.Collection.extend
  model: App.Building

App.buildings = new App.BuildingController

##### ROOMS

App.Room = Backbone.RelationalModel.extend
  relations: [
    type: Backbone.HasMany,
    key: 'devices',
    relatedModel: 'App.Device',
    collectionType: 'App.DeviceController'
    reverseRelation:
      key: 'room',
      includeInJSON: 'id'
    ]


App.RoomController = App.SelectionCollection.extend
  model: App.Room

App.rooms = new App.RoomController

##### DEVICES

App.Device = Backbone.RelationalModel.extend
  driver: () -> App.drivers.get_by_name(@get("driver"))

  state_vars: () -> @get("params")?.state_vars

  vars_array: () ->
    state_vars = @state_vars()
    _(state_vars).chain().keys().map (k) ->
      h = state_vars[k]
      h.name = k
      h
    .value()

  display_vars: () ->
    _(@vars_array()).chain()
      .filter((h) -> h.display_order)
      .sortBy((h) -> h.display_order)
      .value()

  controllable_vars: () ->


App.DeviceController = App.SelectionCollection.extend
  model: App.Device

App.devices = new App.DeviceController

##### DRIVERS

App.Driver = Backbone.Model.extend()

App.DriverController = Backbone.Collection.extend
  model: App.Driver
  get_by_name: (name) ->
    @find((d) -> d.get('name') == name)

App.drivers = new App.DriverController


