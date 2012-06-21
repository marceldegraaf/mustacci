require 'couchrest'

module Mustacci
  class Database

    DATABASE = 'http://localhost:5984/mustacci'

    attr_reader :connection

    def self.reset
      new.connection.delete!
      new
    end

    def initialize
      @connection = CouchRest.database!(DATABASE)
    end

    def get(id)
      connection.get(id)
    end

    def save(document)
      connection.save_doc(document)
    end

    def view(name, params = {})
      connection.view(name, params)['rows']
    rescue RestClient::ResourceNotFound
      []
    end

  end
end
