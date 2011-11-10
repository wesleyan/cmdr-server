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

App.Device = Backbone.RelationalModel.extend()

App.DeviceController = App.SelectionCollection.extend
  model: App.Device

App.devices = new App.DeviceController

##### DRIVERS

App.Driver = Backbone.Model.extend()

App.DriverController = Backbone.Collection.extend
  model: App.Driver

App.drivers = new App.DriverController


