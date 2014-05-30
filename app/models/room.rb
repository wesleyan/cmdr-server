class Room < CouchRest::Model::Base
  use_database 'rooms'

  property :belongs_to, String, default: ''
  property :name, String, default: 'Unnamed'
  property :hostname, String, default: 'localhost'
  property :attrs, default: {} do
    property :name, String, default: 'Unnamed'
    property :hostname, String, default: 'localhost'
    property :mac, String, default: ''
    property :projector, String, default: ''
    property :volume, String, default: ''
    property :switcher, String, default: ''
    property :ir_switcher, String, default: ''
    property :blurayplayer, String, default: ''
    property :computer, String, default: ''
    property :ports, [String], default: []
  end

  design do
    view :by_name
  end

  design do
    view :by_hostname
  end

end
