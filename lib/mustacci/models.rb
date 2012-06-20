require './lib/mustacci'
require 'data_mapper'
require 'fileutils'

FileUtils.mkdir_p File.dirname(Mustacci.database_path)
DataMapper.setup :default, Mustacci.database

module Mustacci

  class Project
    include DataMapper::Resource

    has n, :builds

    property :id,         Serial
    property :name,       String
    property :owner,      String
    property :human_name, String

    def repo
      [ owner, name ].join('/')
    end
  end

  class Build
    include DataMapper::Resource

    belongs_to :project

    property :id,         Serial
    property :built_at,   DateTime
    property :success,    Boolean
    property :building,   Boolean
    property :identifier, String

    def output
      file = File.open("tmp/output/#{identifier}.html")
      file.read
    end
  end

end

DataMapper.auto_upgrade!
