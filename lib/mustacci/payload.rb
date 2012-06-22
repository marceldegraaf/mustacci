require 'json'
require 'ostruct'
require 'time'
require 'mustacci/database'

module Mustacci
  class Payload < OpenStruct

    def self.load(payload_id)
      data = Mustacci::Database.new.get(payload_id)['data']
      new(JSON.parse(data).merge(id: payload_id))
    end

    def self.save(data)
      document = { data: data, type: 'payload' }
      id = Mustacci::Database.new.save(document)['id']
      self.load(id)
    end

    def commits
      super.map { |commit| Commit.new(commit) }
    end

    def repository
      Repository.new(super)
    end

    class Repository < OpenStruct

      def owner
        User.new(super)
      end

      def full_name
        [ owner.name, name ].join('/')
      end

    end

    class Commit < OpenStruct

      def author
        User.new(super)
      end

      def timestamp
        Time.parse(super)
      end

    end

    class User < OpenStruct

    end

  end
end
