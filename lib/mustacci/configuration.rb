require 'logger'

module Mustacci
  # This holds the configuration of Mustacci.
  #
  # When you run `mustacci install` you'll get a configuration file.
  # This configuration can be accessed through the main Mustacci module.
  #
  # Example:
  #
  #   Mustacci.configure do |config|
  #     config.github_auth! "john", "secret"
  #   end
  class Configuration

    # Used to authenticate Github push notifications.
    #
    # When `github_auth` is true, then you need to add the username and
    # password to your github service hook.
    #
    #   http://username:password@mustacci.example.com:8081/github
    #
    attr_accessor :github_auth, :github_username, :github_password

    # The port on which the Github service hook will listen. Defaults to 8081.
    attr_accessor :github_port

    # The port on which the frontend will listen. Defaults to 8080.
    attr_accessor :frontend_port

    # The port on which the websocket will listen. Defaults to 8082.
    attr_accessor :websocket_port

    # Where the 0MQ connects to. Defaults to "tcp://127.0.0.1:9000"
    attr_accessor :queue

    # The hostname of Mustacci
    attr_accessor :hostname

    # Specify a block to determine what should happen on a successful build.
    #
    # Yields a build object.
    #
    # Example:
    #
    #   Mustacci.configure do |config|
    #     config.on_success do |build|
    #       mail build.author
    #     end
    #   end
    attr_accessor :on_success

    # Specify a block to determine what should happen on a failed build.
    #
    # Yields a build object.
    #
    # Example:
    #
    #   Mustacci.configure do |config|
    #     config.on_failed do |build|
    #       mail build.author
    #     end
    #   end
    attr_accessor :on_failed

    # How many workers do you want? Defaults to 1.
    attr_accessor :workers

    # Change the logger. Defaults to $stderr
    #
    # Examples:
    #
    #   config.logger = Logger.new($stderr)
    #   config.logger = Logger.new("mustacci.log")
    attr_accessor :logger

    def initialize
      @frontend_port  = 8080
      @github_port    = 8081
      @websocket_port = 8082
      @on_success     = Proc.new { }
      @on_failed      = Proc.new { }
      @workers        = 1
      @logger         = Logger.new($stderr)
      @queue          = "tcp://127.0.0.1:9001"
    end

    # Sets the github username and password
    def github_auth!(username, password)
      @github_auth     = true
      @github_username = username
      @github_password = password
    end

  end
end
