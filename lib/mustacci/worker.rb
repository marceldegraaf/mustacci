require 'pty'
require 'zmq'
require 'mustacci/runner'

module Mustacci
  class Worker

    include Helpers

    def self.start
      new.run!
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
          Runner.call(data)
        rescue Exception => error
          handle_runner_error inbound, error
        end
      end
    end

    def handle_runner_error(inbound, error)
      $stderr.puts "\e[31m[#{Time.now}] #{error.class}: #{error}\e[0m"
      error.backtrace.each do |line|
        $stderr.puts "      \e[30m#{line}\e[0m"
      end
      inbound.close
      exit 1
    end

  end
end
