require 'ostruct'
require 'time'
require 'mustacci/database'

module Mustacci
  class Build < OpenStruct

    attr_reader :document

    def self.load(id)
      document = Mustacci::Database.new.get(id)
      new(document)
    end

    def self.for_project(project_id)
      Mustacci::Database.new.view('builds/by_project', key: project_id).map do |row|
        new(row['value'].to_hash)
      end
    end

    def self.find(id)
      document = Mustacci::Database.new.get(id)
      new(document.to_hash)
    end

    def initialize(document)
      super(document.to_hash)
      @document = document

      self
    end

    def id
      self._id
    end

    def output
      database.connection.fetch_attachment(self.document, log_filename)
    end

    def running?
      completed == false
    end

    def completed?
      completed == true
    end

    def success?
      completed && success
    end

    def failure
      completed && success == false
    end

    def payload
      Mustacci::Payload.load(self.payload_id)
    end

    def elapsed
      if completed?
        Time.parse(completed_at) - Time.parse(started_at)
      else
        Time.now - Time.parse(started_at)
      end
    end

    def success!
      document = reload
      document['completed'] = true
      document['completed_at'] = Time.now
      document['success'] = true
      document.save
    end

    def failure!
      document = reload
      document['completed'] = true
      document['completed_at'] = Time.now
      document['success'] = false
      document.save
    end

    def complete!
      document = reload
      document['completed'] = true
      document['completed_at'] = Time.now
      document.save
    end

    def save_log(log)
      database.connection.put_attachment(reload, log_filename, log, content_type: "text/html")
    end

    private

    # We need to reload the document to prevent
    # a 409 Conflict error in CouchDB
    def reload
      database.get(self.document['_id'])
    end

    def database
      @database ||= Mustacci::Database.new
    end

    def log_filename
      "output.html"
    end

  end
end
