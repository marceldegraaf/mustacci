require 'couchrest'

module Mustacci
  class Database

    DATABASE = 'http://localhost:5984/mustacci'

    attr_reader :connection

    class DatabaseDown < RuntimeError; end

    def self.reset
      execute do
        new.connection.delete!
        new
      end
    end

    def initialize
      @connection = CouchRest.database!(DATABASE)
    end

    def get(id)
      execute { connection.get(id) }
    end

    def save(document)
      execute { connection.save_doc(document) }
    end

    def view(name, params = {})
      execute do
        begin
          connection.view(name, params)['rows']
        rescue RestClient::ResourceNotFound
          []
        end
      end
    end

    private

      def execute(&block)
        yield
      rescue Errno::ECONNREFUSED
        raise DatabaseDown, 'CouchDB seems to be down.'
      end


  end
end
