class Room
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  @db = CouchRest.database('http://localhost:5984/rooms')

  def self.all
    @db.get('_design/cmdr_web').view('rooms')['rows']
      .map { |doc| doc['value'] }
  end

  def self.find(id)
    @db.get(id).to_hash
  end

  def persisted?
    true
  end
end
