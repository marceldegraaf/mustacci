require 'mustacci'
require 'thor'
ENV['RACK_ENV'] = 'production'

module Mustacci
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      File.expand_path('../templates', __FILE__)
    end

    desc "install DIRECTORY", "Generates the Mustacci configuration"
    method_options :development => false
    def install(directory)
      self.destination_root = directory
      say "Installing Mustacci in #{destination_root}", :yellow

      require 'securerandom'
      @password = SecureRandom.hex(16)
      @username = `whoami`.strip
      @hostname = `hostname`.strip
      @workspace = File.join(destination_root, 'workspace')
      @configuration = Mustacci.configuration

      template "mustacci.rb.tt"
      template "Gemfile.tt"
      template "Procfile.tt"
    end

    desc "github", "Starts just the Github push notification listener"
    def github
      require 'mustacci/github'
      load_configuration!
      Github.start
    end

    desc "worker", "Starts just one worker"
    def worker
      require 'mustacci/worker'
      load_configuration!
      Worker.start
    end

    desc "frontend", "Starts just the frontend and websocket server"
    def frontend
      require 'mustacci/frontend'
      load_configuration!
      Frontend.start
    end

    desc "build ID", "Runs the build called ARG"
    def build(id)
      require 'mustacci/builder'
      load_configuration!
      Builder.run!(id)
    end

    desc "setup", "Creates the views in the database"
    def setup
      if yes? "This will erase all data from the database. Are you sure?"
        require 'mustacci/seed'
        load_configuration!
        Seed.call
      end
    end

    private

    def load_configuration!
      config_file = File.join(directory, "mustacci.rb")
      load config_file if File.exist?(config_file)
    end

    def directory
      Dir.pwd
    end

  end
end
