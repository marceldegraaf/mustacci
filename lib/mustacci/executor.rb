require 'pty'

module Mustacci

  # Wrapper around PTY. Could easily be replaced by Net::SSH or something similar.
  class Executor

    extend Helpers

    def self.call(command)
      info "Running: `#{command}`"
      PTY.spawn command do |read, write, pid|
        begin
          read.each_char do |char|
            yield char
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
      warn "The runner process started in Mustacci::Worker exited"
    end

  end
end
