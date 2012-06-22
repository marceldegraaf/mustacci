require 'mustacci/publisher'
require 'mustacci/executor'

module Mustacci
  class Runner

    include Helpers

    def self.call(data)
      new(data).process
    end

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def process
      info "Starting build. Build id: #{build.id}"
      publisher.start
      Executor.call(command) do |char|
        publisher << char
      end
    ensure
      finish
    end

    private

    def command
      "bundle exec mustacci build #{build.id.inspect}"
    end

    def finish
      build.complete! unless build.completed?
      build.save_log(publisher.output)
      info "Done building for build id: #{build.id}"
    end

    def payload
      @payload ||= Payload.save(data)
    end

    def project
      @project ||= find_or_create_project
    end

    def build
      @build = create_build(project.id)
    end


    def find_or_create_project
      project = database.view('projects/by_name', key: repository_name)

      if project.any?
        project = project.first['value']
      else
        project = {
          type: 'project',
          name: payload.repository.name,
          owner: payload.repository.owner.name
        }
        database.save( project )
        project
      end

      Mustacci::Project.new(project)
    end

    def create_build(project_id)
      build = {
        type: 'build',
        project_id: project_id,
        payload_id: @payload.id,
        success: false,
        completed: false,
        started_at: Time.now
      }

      database.save(build)
      Mustacci::Build.load(build['_id'])
    end

    def repository_name
      [ payload.repository.owner.name, payload.repository.name ].join('/')
    end

    def database
      @database ||= Database.new
    end

    def publisher
      @publisher ||= Publisher.new(build, project)
    end

  end
end
