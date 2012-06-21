require 'pty'
require 'digest'
require 'fileutils'
require 'net/http'
require 'json'
require 'mustacci/database'
require 'mustacci/payload'
require 'mustacci/project'
require 'mustacci/build'

module Mustacci
  class Worker

    WS = "http://127.0.0.1:9393/faye"

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def run!
      @payload = Mustacci::Payload.save(@data)

      @project = find_or_create_project
      @build = create_build(@project.id)

      Mustacci.log "Starting build. Build id: #{@build.id}"
      Mustacci.log "Sending output to channel: #{channel}"

      output = ''

      PTY.spawn "./script/runner #{@build.id}" do |read, write, pid|
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
      end

      @build.save_log(output)

      Mustacci.log "Done building for build id: #{@build.id}"
    end

    private

      def find_or_create_project
        project = database.view('projects/by_name', key: repository_name)
        Mustacci.log repository_name
        Mustacci.log project.inspect

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
        Mustacci::Build.new(build)
      end

      def write_to_websocket(line)
        begin
          message = { channel: channel, data: { text: line } }
          Net::HTTP.post_form(socket, message: message.to_json)
        rescue Errno::ECONNREFUSED
          Mustacci.log line
        end
      end

      def socket
        @ws ||= URI.parse(WS)
      end

      def channel
        "/build/#{@build.id}"
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
