module Mustacci

  class << self

    def log(message)
      $stdout.puts "\e[33m[#{Time.now}] #{message}\e[0m"
    end

    def root
      File.join(File.dirname(__FILE__), '..')
    end

    def database
      "sqlite://#{database_path}"
    end

    def database_path
      File.join(Mustacci.root, 'db', 'mustacci.sqlite')
    end

  end

end
