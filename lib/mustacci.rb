module Mustacci

  class << self

    def log(message)
      $stdout.puts "\e[33m[#{Time.now}] #{message}\e[0m"
    end

  end

end
