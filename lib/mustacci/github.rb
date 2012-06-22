require 'sinatra/base'
require 'zmq'

module Mustacci
  class Github < Sinatra::Base

    def self.start
      set :mustacci, Mustacci.configuration
      set :port, Mustacci.configuration.github_port
      set :environment, :production
      enable :logging
      enable_auth if Mustacci.configuration.github_auth
      run!
    end

    def self.enable_auth
      use Rack::Auth::Basic, "Mustacci" do |username, password|
        ([username, password] == [settings.mustacci.github_username, settings.mustacci.github_password]).tap do |success|
          logger.info "Invalid credentials sent from #{request.ip}"
        end
      end
    end

    post '/github' do
      if params[:payload]
        logger.info "Received payload from #{request.ip}"
        outbound.send params[:payload]
        "Thank you for this delicious payload!\n\n"
      else
        logger.info "Received invalid request from #{request.ip}"
        400
      end
    end

    def outbound
      @outbound ||= begin
                      context = ZMQ::Context.new(1)
                      outbound = context.socket(ZMQ::DOWNSTREAM)
                      outbound.connect settings.mustacci.queue
                      outbound
                    end
    end

  end
end
