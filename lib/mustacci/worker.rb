require 'pty'
require 'net/http'
require 'zmq'
require 'mustacci'
require 'mustacci/database'
require 'mustacci/payload'
require 'mustacci/project'
require 'mustacci/build'

module Mustacci
  class Worker

    def self.start(configuration)
      new(configuration).run!
    end

    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def run!
      info "Starting worker listening on #{configuration.queue}"
      context = ZMQ::Context.new(1)
      inbound = context.socket(ZMQ::UPSTREAM)
      inbound.bind configuration.queue

      loop do
        trap('INT') do
          info 'Exit signal received, shutting down...'
          inbound.close
          exit
        end

        data = inbound.recv
        begin
          process(data)
        rescue Exception => error
          $stderr.puts "\e[31m[#{Time.now}] #{error.class}: #{error}\e[0m"
          error.backtrace.each do |line|
            $stderr.puts "      \e[30m#{line}\e[0m"
          end
          inbound.close
          exit 1
        end
      end
    end

    private

    def process(data)
      info "Received payload in worker"
      @payload = Payload.save(data)

      @project = find_or_create_project
      @build = create_build(@project.id)

      info "Starting build. Build id: #{@build.id}"
      info "Sending output to channels: #{channels.join(', ')}"

      output = ''

      PTY.spawn "./script/runner #{@build.id}" do |read, write, pid|

        read.each_line do |line|
          line = clean(line)
          write_to_websocket(line)
          output << line
        end
      end

      @build.save_log(output)

      info "Done building for build id: #{@build.id}"
    end

    def find_or_create_project
      project = database.view('projects/by_name', key: repository_name)
      info repository_name
      info project.inspect

      if project.any?
        project = project.first['value']
      else
        project = { type: 'project', name: @payload.repository.name, owner: @payload.repository.owner.name }
        database.save( project )
        project
      end

      Project.new(project)
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
      Build.new(build)
    end

    def write_to_websocket(line)
      begin
        channels.each do |channel|
          message = { channel: channel, data: { text: line } }
          Net::HTTP.post_form(socket, message: message.to_json)
        end
      rescue Errno::ECONNREFUSED
        info line
      end
    end

    def socket
      @ws ||= URI.parse("http://#{configuration.hostname}:#{configuration.websocket_port}/faye")
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
      @database ||= Database.new
    end

    def info(*args)
      configuration.logger.info(*args)
    end

  end
end
