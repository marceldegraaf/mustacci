require 'mustacci'
require 'mustacci/github'
require 'mustacci/frontend'
require 'mustacci/worker'
require 'thor'
require 'foreman'
require 'foreman/cli'

module Mustacci
  class CLI < Thor

    desc "install", "Generates the Mustacci configuration"
    def install
      puts "Installing Mustacci... hold on!"
      # Should write a Gemfile and a mustacci config
      # also generate empty directories, for log and workspace
    end

    desc "start", "Starts up Mustacci servers"
    def start
      Foreman::CLI.start(["start", "--procfile", procfile, "--app-root", directory])
    end

    desc "github", "Starts the Github push notification listener"
    def github
      load_configuration
      Github.start(configuration)
    end

    desc "worker", "Starts a worker"
    def worker
      load_configuration
      Worker.start(configuration)
    end

    desc "frontend", "Starts the frontend and websocket"
    def frontend
      load_configuration
      Frontend.start(configuration)
    end

    desc "build ID", "Runs a build"
    def build(id)
      load_configuration
      configuration.logger "This needs to be done still"
    end

    private

    def procfile
      File.expand_path("../procfile.yml", __FILE__)
    end

    def directory
      @directory ||= Dir.pwd
    end

    def load_configuration
      config_file = File.join(directory, "config.rb")
      load config_file if File.exist?(config_file)
    end

    def configuration
      Mustacci.configuration
    end

  end
end
