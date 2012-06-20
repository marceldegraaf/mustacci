require 'pty'
require 'digest'
require 'fileutils'
require 'net/http'
require 'json'

module Mustacci
  class Worker

    WS = "http://127.0.0.1:9393/faye"

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def run!
      filename = "tmp/payloads/#{Digest::MD5.hexdigest(@data)}.json"
      FileUtils.mkdir_p File.dirname(filename)
      File.open(filename, 'w:utf-8') { |f| f << @data }

      prepare_output_file

      Mustacci.log "Starting build."
      Mustacci.log "Sending output to channel: #{channel}"

      PTY.spawn "./script/runner #{filename}" do |read, write, pid|
        line = ''

        read.each_char do |char|
          line << char

          # Send output to web socket per line, not per character
          if char == "\n"
            line = clean(line)
            write_to_websocket(line)
            write_to_output_file(line)
            line = ''
          end
        end
      end

      # Write the build output to a file
      close_output_file

      Mustacci.log "Output written to file: #{@output_path}"
      Mustacci.log "Done with this build."
    end

    private

      def write_to_websocket(line)
        begin
          message = { channel: channel, data: { text: line } }
          Net::HTTP.post_form(socket, message: message.to_json)
        rescue Errno::ECONNREFUSED
          Mustacci.log 'Could not reach Faye'
        end
      end

      def socket
        @ws ||= URI.parse(WS)
      end

      def write_to_output_file(line)
        @output_file << line
      end

      def channel
        "/build/#{repo}"
      end

      def repo
        begin
          hash = JSON.parse(@data)
          hash['repository']['url'].scan(/:(\w+\/\w+)/).first.first
        rescue
          ''
        end
      end

      def prepare_output_file
        @output_path = "tmp/output/#{Digest::MD5.hexdigest(@data)}.html"
        FileUtils.mkdir_p File.dirname(@output_path)
        @output_file = File.open(@output_path, 'w:utf-8')
      end

      def close_output_file
        @output_file.close
      end

      def clean(line)
        line.gsub!("\e[0m", '</span>')
        line.gsub!(/\e\[(\d+)m/, '<span class="color_\\1">')
        line.gsub!(/\s{4}/, '&nbsp;&nbsp;&nbsp;&nbsp;')
        line.gsub!("\r\n", '<br>')
      end

  end
end
