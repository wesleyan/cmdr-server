class Room < CouchRest::Model::Base
  use_database 'rooms'

  property :belongs_to, String
  property :name, String
  property :attrs, Hash

  design do
    view :by_name
  end
end
