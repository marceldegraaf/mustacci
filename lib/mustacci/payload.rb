require 'json'
require 'ostruct'
require 'time'

module Mustacci
  class Payload < OpenStruct

    def self.load(filename)
      new(JSON.parse(File.open(filename, 'r:utf-8').read))
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
