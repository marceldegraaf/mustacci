require 'pty'
require 'digest'
require 'fileutils'
require 'net/http'
require 'json'
require 'mustacci'
require 'mustacci/database'
require 'mustacci/payload'
require 'mustacci/project'
require 'mustacci/build'

module Mustacci
  class Worker

    WS = "http://#{Mustacci.config.sinatra.hostname}:9393/faye"

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def run!
      @payload = Mustacci::Payload.save(@data)

      @project = find_or_create_project
      @build = create_build(@project.id)

      Mustacci.log "Starting build. Build id: #{@build.id}"
      Mustacci.log "Sending output to channels: #{channels.join(', ')}"

      output = ''

      begin
        PTY.spawn "./script/runner #{@build.id}" do |read, write, pid|
          begin
            line = ''

            read.each_char do |char|
              line << char

              # Send output to web socket per line, not per character
              if char == "\n"
                line = clean(line)
                write_to_websocket(line)
                output << line
                line = ''
              end
            end
          rescue Errno::EIO
            # This "error" is raised when the child process is done sending I/O
            # to the pty. For some reason Ruby does not handle this standard
            # behavior very well.
            #
            # See: http://stackoverflow.com/questions/1154846/continuously-read-from-stdout-of-external-process-in-ruby
          end
        end
      rescue PTY::ChildExited
        Mustacci.log "The runner process started in Mustacci::Worker exited"
      ensure
        @build.complete! unless @build.completed?
        @build.save_log(output)
      end

      Mustacci.log "Done building for build id: #{@build.id}"
    end

    private

      def find_or_create_project
        project = database.view('projects/by_name', key: repository_name)

        if project.any?
          project = project.first['value']
        else
          project = { type: 'project', name: @payload.repository.name, owner: @payload.repository.owner.name }
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

      def write_to_websocket(line)
        begin
          channels.each do |channel|
            message = { channel: channel, data: { text: line } }
            Net::HTTP.post_form(socket, message: message.to_json)
          end
        rescue Errno::ECONNREFUSED
          Mustacci.log line
        end
      end

      def socket
        @ws ||= URI.parse(WS)
      end

      def channels
        [
          "/build/#{@build.id}",
          "/build/#{@project.id}"
        ]
      end

      def repository_name
        [ @payload.repository.owner.name, @payload.repository.name ].join('/')
      end

      def clean(line)
        line.gsub!("\e[0m", '</span>')
        line.gsub!(/\e\[(\d+)m/, '<span class="color_\\1">')
        line.gsub!(/\s{4}/, '&nbsp;&nbsp;&nbsp;&nbsp;')
        line.gsub!("\r\n", '<br>')
      end

      def database
        @database ||= Mustacci::Database.new
      end

  end
end
