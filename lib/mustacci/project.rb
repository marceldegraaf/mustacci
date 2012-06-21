require 'ostruct'
require 'mustacci/database'

module Mustacci
  class Project < OpenStruct

    def self.all
      Mustacci::Database.new.view('projects/by_name').map do |row|
        new(row['value'].to_hash)
      end
    end

    def self.find(id)
      document = Mustacci::Database.new.get(id)
      new(document.to_hash)
    end

    def repo_name
      [ owner, name ].join('/')
    end

    def builds
      Mustacci::Build.
        for_project(self.id).
        sort_by(&:started_at).
        reverse
    end

    def id
      self._id
    end

  end
end
