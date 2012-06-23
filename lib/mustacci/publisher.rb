require 'json'
require 'net/http'

module Mustacci
  class Publisher

    include Helpers

    attr_reader :build, :project, :output

    def initialize(build, project)
      @build = build
      @project = project
      @output = ''
      @buffer = ''
    end

    def start
      notify_websocket
    end

    def <<(cha)
      char = cha.dup
      $stderr.print char
      $stderr.flush
      buffer char
      flush if should_buffer?
    end

    def should_buffer?
      (Time.now - @last_buffered) > 0.15
    end

    def buffer(text)
      @output << text
      @buffer << text
    end

    def flush
      text, @buffer = @buffer, ''
      clean! text
      write_to_websocket text
    end

    def write_to_websocket(line)
      reset_timer
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
      @socket ||= URI.parse("http://localhost:#{configuration.frontend_port}/faye")
    end

    def reset_timer
      @last_buffered = Time.now
    end

    def notify_websocket
      info "Posting to #{socket}"
      write_to_websocket("START")
    end

    def clean!(text)
      text.gsub!(/\e?\[0m/, '</span>')
      text.gsub!(/\e?\[(\d+)m/, '<span class="color_\\1">')
      text.gsub!(/\s{4}/, '&nbsp;&nbsp;&nbsp;&nbsp;')
      text.gsub!("\r\n", '<br>')
    end

    def channels
      [
        "/build/#{build.id}",
        "/build/#{project.id}"
      ]
    end

  end
end
