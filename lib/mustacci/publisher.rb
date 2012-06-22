require 'json'
require 'net/http'

module Mustacci
  class Publisher

    include Helpers

    attr_reader :build, :project, :output

    def initialize(build, project)
      @build = build
      @project = project
    end

    def start
      @line = ''
      @output = ''
      notify_websocket
    end

    def <<(info)
      @line << info
      # Send output to web socket per line, not per character
      if info == "\n"
        clean!
        write_to_websocket(@line)
        output << @line
        @line = ''
      end
    end

    def write_to_websocket(line)
      begin
        channels.each do |channel|
          message = { channel: channel, data: { text: line } }
          Net::HTTP.post_form(socket, message: message.to_json)
        end
      rescue Errno::ECONNREFUSED
        warn line
      end
    end

    def socket
      @ws ||= URI.parse("http://#{configuration.hostname}:#{configuration.websocket_port}/faye")
    end

    def notify_websocket
      write_to_websocket("START")
    end

    def clean!
      @line.gsub!("\e[0m", '</span>')
      @line.gsub!(/\e\[(\d+)m/, '<span class="color_\\1">')
      @line.gsub!(/\s{4}/, '&nbsp;&nbsp;&nbsp;&nbsp;')
      @line.gsub!("\r\n", '<br>')
    end

    def channels
      [
        "/build/#{build.id}",
        "/build/#{project.id}"
      ]
    end

  end
end
