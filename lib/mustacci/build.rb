require 'ostruct'
require 'time'
require './lib/mustacci/database'

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
      database.connection.fetch_attachment(self.document, "output.html")
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
      self.document['completed'] = true
      self.document['completed_at'] = Time.now
      self.document['success'] = true
      self.document.save
    end

    def failure!
      self.document['completed'] = true
      self.document['completed_at'] = Time.now
      self.document['success'] = false
      self.document.save
    end

    def save_log(log)
      # We need to reload the document to prevent a 409 Conflict error
      reloaded_document = database.get(self.document['_id'])

      database.connection.put_attachment(reloaded_document, "output.html", log, content_type: "text/html")
    end

    private

      def database
        @database ||= Mustacci::Database.new
      end

  end
end
