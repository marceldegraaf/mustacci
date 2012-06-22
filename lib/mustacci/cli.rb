require 'mustacci'
require 'thor'
require 'fileutils'

module Mustacci
  class CLI < Thor
    include FileUtils

    class_option :directory, :default => nil, :desc => "The directory that the configuration lives in"

    desc "install DIRECTORY", "Generates the Mustacci configuration"
    def install(directory)
      mkdir_p directory
      source_root = File.expand_path('../../../templates', __FILE__)
      cp File.join(source_root, 'config.rb'), File.join(directory, 'config.rb')
      cp File.join(source_root, 'Gemfile'), File.join(directory, 'Gemfile')
    end

    desc "start", "Starts up Mustacci servers"
    def start
      require 'foreman'
      require 'foreman/cli'
      procfile = File.expand_path("../procfile.yml", __FILE__)
      Foreman::CLI.start(["start", "--procfile", procfile, "--app-root", directory])
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
      Mustacci.configuration.logger.info "Building #{id}"
      Builder.run!(id)
    end

    private

    def load_configuration!
      config_file = File.join(directory, "config.rb")
      load config_file if File.exist?(config_file)
    end

    def directory
      options.directory || Dir.pwd
    end

  end
end
